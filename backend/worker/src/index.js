import { verifyFirebaseToken } from "./firebase-auth.js";
import { generateGeminiReply } from "./gemini.js";

const ALLOWED_LANGUAGES = new Set(["ar", "fr", "en", "es"]);
const MAX_MESSAGE_CHARS = 2000;
const MAX_BODY_BYTES = 8192;

function json(data, status, headers = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "content-type": "application/json; charset=utf-8", ...headers },
  });
}

function corsHeaders(origin, env) {
  const headers = { "vary": "Origin" };
  if (origin && origin === env.ALLOWED_ORIGIN) {
    headers["access-control-allow-origin"] = origin;
    headers["access-control-allow-methods"] = "POST, GET, OPTIONS";
    headers["access-control-allow-headers"] = "Authorization, Content-Type, Accept";
    headers["access-control-max-age"] = "600";
  }
  return headers;
}

function isAllowedOrigin(origin, env) {
  return !origin || origin === env.ALLOWED_ORIGIN;
}

export function createWorker(deps = {}) {
  const verifyToken = deps.verifyFirebaseToken || verifyFirebaseToken;
  const generateReply = deps.generateGeminiReply || generateGeminiReply;

  return {
    async fetch(request, env) {
      const url = new URL(request.url);
      const origin = request.headers.get("origin");
      const headers = corsHeaders(origin, env);

      if (!isAllowedOrigin(origin, env)) {
        return json({ error: "origin_not_allowed" }, 403);
      }

      if (request.method === "OPTIONS") {
        return new Response(null, { status: 204, headers });
      }

      if (url.pathname === "/health" && request.method === "GET") {
        return json({ status: "ok" }, 200, headers);
      }

      if (url.pathname !== "/api/chat" || request.method !== "POST") {
        return json({ error: "not_found" }, 404, headers);
      }

      const contentLength = Number(request.headers.get("content-length") || 0);
      if (contentLength > MAX_BODY_BYTES) {
        return json({ error: "payload_too_large" }, 413, headers);
      }

      // Cloudflare Rate Limiting binding is configured in wrangler.toml.
      // Its counters are location-scoped and therefore an edge abuse guard,
      // not a globally exact per-user quota.
      if (env.CHAT_LIMITER) {
        const key = request.headers.get("cf-connecting-ip") || "unknown-client";
        const result = await env.CHAT_LIMITER.limit({ key });
        if (!result.success) return json({ error: "rate_limited" }, 429, headers);
      }

      const authorization = request.headers.get("authorization") || "";
      const match = /^Bearer ([^\s]+)$/.exec(authorization);
      if (!match) return json({ error: "unauthorized" }, 401, headers);

      let identity;
      try {
        identity = await verifyToken(match[1], env);
      } catch {
        return json({ error: "unauthorized" }, 401, headers);
      }

      let body;
      try {
        const raw = await request.text();
        if (new TextEncoder().encode(raw).byteLength > MAX_BODY_BYTES) {
          return json({ error: "payload_too_large" }, 413, headers);
        }
        body = JSON.parse(raw);
      } catch {
        return json({ error: "bad_request" }, 400, headers);
      }

      const message = typeof body?.message === "string" ? body.message.trim() : "";
      const language = typeof body?.language === "string" ? body.language : "";
      if (!message || message.length > MAX_MESSAGE_CHARS ||
          !ALLOWED_LANGUAGES.has(language)) {
        return json({ error: "invalid_request" }, 400, headers);
      }

      try {
        const reply = await generateReply({ message, language, uid: identity.uid, env });
        if (typeof reply !== "string" || !reply.trim()) {
          return json({ error: "upstream_invalid_response" }, 502, headers);
        }
        return json({ reply: reply.trim() }, 200, headers);
      } catch (error) {
        if (error?.name === "AbortError" || error?.name === "TimeoutError") {
          return json({ error: "upstream_timeout" }, 504, headers);
        }
        // Never log tokens, prompts, provider responses or secret-bearing errors.
        console.error("AI provider request failed");
        return json({ error: "upstream_unavailable" }, 502, headers);
      }
    },
  };
}

const worker = createWorker();
export default worker;
