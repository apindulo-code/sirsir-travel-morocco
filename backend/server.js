import express from "express";
import cors from "cors";
import helmet from "helmet";
import { rateLimit } from "express-rate-limit";
import { applicationDefault, getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

const PORT = Number.parseInt(process.env.PORT || "8080", 10);
const GEMINI_MODEL = process.env.GEMINI_MODEL || "gemini-3.8-flash";
const GEMINI_TIMEOUT_MS = Number.parseInt(process.env.GEMINI_TIMEOUT_MS || "30000", 10);
const ALLOWED_ORIGIN = process.env.ALLOWED_ORIGIN || "";
const MAX_MESSAGE_CHARS = 2000;
const ALLOWED_LANGUAGES = new Set(["ar", "fr", "en", "es"]);

function validateEnvironment() {
  if (!process.env.GEMINI_API_KEY) throw new Error("Missing GEMINI_API_KEY");
  if (!ALLOWED_ORIGIN) throw new Error("Missing ALLOWED_ORIGIN");
  const origin = new URL(ALLOWED_ORIGIN);
  if (!["http:", "https:"].includes(origin.protocol) || origin.origin !== ALLOWED_ORIGIN) {
    throw new Error("ALLOWED_ORIGIN must be one exact origin, without a path");
  }
  if (!Number.isInteger(PORT) || PORT < 1 || PORT > 65535) throw new Error("Invalid PORT");
  if (!Number.isInteger(GEMINI_TIMEOUT_MS) || GEMINI_TIMEOUT_MS < 1000 || GEMINI_TIMEOUT_MS > 120000) {
    throw new Error("GEMINI_TIMEOUT_MS must be between 1000 and 120000");
  }
}

function createApp({ auth, generateReply }) {
  const app = express();
  app.disable("x-powered-by");
  app.use(helmet());
  app.use(cors({
    origin(origin, callback) {
      // Native mobile clients may omit Origin. Browser requests must match the allowlist.
      if (!origin || origin === ALLOWED_ORIGIN) return callback(null, true);
      return callback(new Error("Origin not allowed"));
    },
    methods: ["POST", "GET", "OPTIONS"],
    allowedHeaders: ["Authorization", "Content-Type", "Accept"],
    maxAge: 600,
  }));
  app.use(express.json({ limit: "8kb", strict: true }));
  app.get("/health", (_req, res) => res.status(200).json({ status: "ok" }));

  app.use("/api/", rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 20,
    standardHeaders: "draft-8",
    legacyHeaders: false,
    message: { error: "rate_limited" },
  }));

  app.post("/api/chat", async (req, res) => {
    const authorization = req.get("authorization") || "";
    const match = /^Bearer ([^\s]+)$/.exec(authorization);
    if (!match) return res.status(401).json({ error: "unauthorized" });

    let decoded;
    try {
      decoded = await auth.verifyIdToken(match[1], true);
    } catch {
      return res.status(401).json({ error: "unauthorized" });
    }

    const message = typeof req.body?.message === "string" ? req.body.message.trim() : "";
    const language = typeof req.body?.language === "string" ? req.body.language : "";
    if (!message || message.length > MAX_MESSAGE_CHARS || !ALLOWED_LANGUAGES.has(language)) {
      return res.status(400).json({ error: "invalid_request" });
    }

    try {
      const reply = await generateReply({ message, language, uid: decoded.uid });
      if (typeof reply !== "string" || !reply.trim()) {
        return res.status(502).json({ error: "upstream_invalid_response" });
      }
      return res.status(200).json({ reply: reply.trim() });
    } catch (error) {
      if (error?.name === "TimeoutError" || error?.name === "AbortError") {
        return res.status(504).json({ error: "upstream_timeout" });
      }
      // Do not log request bodies, tokens, provider URLs, or secret-bearing errors.
      console.error("AI provider request failed");
      return res.status(502).json({ error: "upstream_unavailable" });
    }
  });

  app.use((error, _req, res, _next) => {
    if (error?.type === "entity.too.large") return res.status(413).json({ error: "payload_too_large" });
    if (error?.message === "Origin not allowed") return res.status(403).json({ error: "origin_not_allowed" });
    return res.status(400).json({ error: "bad_request" });
  });
  return app;
}

async function generateGeminiReply({ message, language }) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), GEMINI_TIMEOUT_MS);
  try {
    const endpoint = new URL(
      `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(GEMINI_MODEL)}:generateContent`,
    );
    endpoint.searchParams.set("key", process.env.GEMINI_API_KEY);
    const response = await fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      signal: controller.signal,
      body: JSON.stringify({
        systemInstruction: {
          parts: [{
            text: "You are SirSir Travel Morocco's travel assistant. Be accurate, practical and transparent. Never invent live availability, prices, schedules, visa rules or bookings. Direct users to official sources for current requirements. Answer in the requested language: " + language + ".",
          }],
        },
        contents: [{ role: "user", parts: [{ text: message }] }],
        generationConfig: { temperature: 0.4, maxOutputTokens: 2048 },
      }),
    });
    if (!response.ok) throw new Error("Gemini provider returned a non-success status");
    const data = await response.json();
    return data?.candidates?.[0]?.content?.parts
      ?.map((part) => typeof part.text === "string" ? part.text : "")
      .join("")
      .trim() || "";
  } finally {
    clearTimeout(timer);
  }
}

async function main() {
  validateEnvironment();
  if (getApps().length === 0) initializeApp({ credential: applicationDefault() });
  const auth = getAuth();
  const app = createApp({ auth, generateReply: generateGeminiReply });
  app.listen(PORT, "0.0.0.0", () => {
    console.log(`SirSir AI backend listening on port ${PORT}`);
  });
}

if (process.env.NODE_ENV !== "test") {
  main().catch(() => {
    console.error("Backend startup failed: check required environment and identity configuration");
    process.exit(1);
  });
}

export { createApp, validateEnvironment };
