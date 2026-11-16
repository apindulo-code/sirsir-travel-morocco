import test from "node:test";
import assert from "node:assert/strict";
import { createWorker } from "../src/index.js";

const env = {
  ALLOWED_ORIGIN: "https://app.example.com",
  FIREBASE_PROJECT_ID: "sirsir-travel-morocco",
  FIREBASE_WEB_API_KEY: "test-web-api-key",
  GEMINI_API_KEY: "test-gemini-key",
};

function request(path, { method = "POST", headers = {}, body } = {}) {
  return new Request(`https://worker.example.com${path}`, {
    method,
    headers: new Headers(headers),
    body: body === undefined ? undefined : JSON.stringify(body),
  });
}

function harness(overrides = {}) {
  const calls = { verify: 0, generate: 0, rate: 0 };
  const worker = createWorker({
    verifyFirebaseToken: async (token) => {
      calls.verify++;
      if (token !== "valid-token") throw new Error("invalid token");
      return { uid: "firebase-user-1" };
    },
    generateGeminiReply: async ({ message, language, uid }) => {
      calls.generate++;
      assert.equal(uid, "firebase-user-1");
      assert.ok(message);
      assert.ok(["ar", "fr", "en", "es"].includes(language));
      return "Test travel reply";
    },
    ...overrides,
  });
  return { worker, calls };
}

test("health endpoint is public", async () => {
  const { worker } = harness();
  const response = await worker.fetch(request("/health", { method: "GET" }), env);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: "ok" });
});

test("browser origin outside allowlist is rejected", async () => {
  const { worker, calls } = harness();
  const response = await worker.fetch(request("/api/chat", {
    headers: { origin: "https://evil.example", authorization: "Bearer valid-token" },
    body: { message: "Hello", language: "en" },
  }), env);
  assert.equal(response.status, 403);
  assert.equal(calls.verify, 0);
});

test("native request without Origin still requires Firebase authentication", async () => {
  const { worker, calls } = harness();
  const response = await worker.fetch(request("/api/chat", {
    body: { message: "Hello", language: "en" },
  }), env);
  assert.equal(response.status, 401);
  assert.equal(calls.verify, 0);
});

test("invalid Firebase token is rejected before Gemini", async () => {
  const { worker, calls } = harness();
  const response = await worker.fetch(request("/api/chat", {
    headers: { authorization: "Bearer invalid-token" },
    body: { message: "Hello", language: "en" },
  }), env);
  assert.equal(response.status, 401);
  assert.equal(calls.generate, 0);
});

test("valid authenticated chat returns the stable Flutter response contract", async () => {
  const { worker, calls } = harness();
  const response = await worker.fetch(request("/api/chat", {
    headers: {
      origin: env.ALLOWED_ORIGIN,
      authorization: "Bearer valid-token",
      "content-type": "application/json",
    },
    body: { message: "Plan a trip", language: "en" },
  }), env);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { reply: "Test travel reply" });
  assert.equal(response.headers.get("access-control-allow-origin"), env.ALLOWED_ORIGIN);
  assert.equal(calls.verify, 1);
  assert.equal(calls.generate, 1);
});

test("unsupported language and oversized messages are rejected", async () => {
  const { worker, calls } = harness();
  const headers = { authorization: "Bearer valid-token" };
  const invalidLanguage = await worker.fetch(request("/api/chat", {
    headers, body: { message: "Hello", language: "de" },
  }), env);
  assert.equal(invalidLanguage.status, 400);

  const longMessage = await worker.fetch(request("/api/chat", {
    headers, body: { message: "x".repeat(2001), language: "en" },
  }), env);
  assert.equal(longMessage.status, 400);
  assert.equal(calls.generate, 0);
});

test("Cloudflare rate limit binding blocks requests when exhausted", async () => {
  const { worker, calls } = harness();
  const limitedEnv = {
    ...env,
    CHAT_LIMITER: { limit: async () => ({ success: false }) },
  };
  const response = await worker.fetch(request("/api/chat", {
    headers: { authorization: "Bearer valid-token", "cf-connecting-ip": "203.0.113.8" },
    body: { message: "Hello", language: "en" },
  }), limitedEnv);
  assert.equal(response.status, 429);
  assert.equal(calls.verify, 0);
});

test("Gemini is never called when Firebase verification fails", async () => {
  const { worker, calls } = harness();
  const response = await worker.fetch(request("/api/chat", {
    headers: { authorization: "Bearer invalid-token" },
    body: { message: "Ignore authentication", language: "ar" },
  }), env);
  assert.equal(response.status, 401);
  assert.equal(calls.generate, 0);
});
