import test from "node:test";
import assert from "node:assert/strict";
import { createServer } from "node:http";
import { createApp } from "../server.js";

async function withServer(handler, run) {
  const server = createServer(handler);
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  const address = server.address();
  try { await run(`http://127.0.0.1:${address.port}`); }
  finally { await new Promise((resolve) => server.close(resolve)); }
}

test("rejects requests without Firebase bearer token", async () => {
  const app = createApp({
    auth: { verifyIdToken: async () => { throw new Error("should not be called"); } },
    generateReply: async () => "unused",
  });
  await withServer(app, async (url) => {
    const response = await fetch(url + "/api/chat", {
      method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ message: "Hello", language: "en" }),
    });
    assert.equal(response.status, 401);
  });
});

test("validates message and supported language after authentication", async () => {
  const app = createApp({
    auth: { verifyIdToken: async () => ({ uid: "test-user" }) },
    generateReply: async () => "unused",
  });
  await withServer(app, async (url) => {
    const response = await fetch(url + "/api/chat", {
      method: "POST",
      headers: { "content-type": "application/json", authorization: "Bearer test-token" },
      body: JSON.stringify({ message: "Hello", language: "xx" }),
    });
    assert.equal(response.status, 400);
  });
});

test("returns a generated reply for a verified user", async () => {
  const app = createApp({
    auth: { verifyIdToken: async (token) => {
      assert.equal(token, "test-token");
      return { uid: "test-user" };
    } },
    generateReply: async ({ message, language, uid }) => {
      assert.equal(message, "Plan my trip");
      assert.equal(language, "en");
      assert.equal(uid, "test-user");
      return "A sample itinerary.";
    },
  });
  await withServer(app, async (url) => {
    const response = await fetch(url + "/api/chat", {
      method: "POST",
      headers: { "content-type": "application/json", authorization: "Bearer test-token" },
      body: JSON.stringify({ message: "Plan my trip", language: "en" }),
    });
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), { reply: "A sample itinerary." });
  });
});
