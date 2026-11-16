const DEFAULT_MODEL = "gemini-3.8-flash";

export async function generateGeminiReply({ message, language, env, fetchImpl = fetch }) {
  if (!env.GEMINI_API_KEY) throw new Error("Gemini secret is not configured");
  const model = env.GEMINI_MODEL || DEFAULT_MODEL;
  const endpoint = new URL(
    `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent`,
  );

  const controller = new AbortController();
  const timeoutMs = Math.min(
    Math.max(Number(env.GEMINI_TIMEOUT_MS) || 30000, 1000),
    55000,
  );
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetchImpl(endpoint, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-goog-api-key": env.GEMINI_API_KEY,
      },
      signal: controller.signal,
      body: JSON.stringify({
        systemInstruction: {
          parts: [{
            text: "You are SirSir Travel Morocco's travel assistant. Be accurate, practical and transparent. Never invent live availability, prices, schedules, visa rules or bookings. Direct users to official sources for current requirements. Answer in the requested language: " + language + ". Do not request or expose passwords, identity documents, payment details or authentication tokens.",
          }],
        },
        contents: [{ role: "user", parts: [{ text: message }] }],
        generationConfig: { temperature: 0.4, maxOutputTokens: 2048 },
      }),
    });

    if (!response.ok) throw new Error("Gemini provider request failed");
    const data = await response.json();
    const reply = data?.candidates?.[0]?.content?.parts
      ?.map((part) => typeof part.text === "string" ? part.text : "")
      .join("")
      .trim();
    if (!reply) throw new Error("Gemini returned an empty response");
    return reply;
  } finally {
    clearTimeout(timer);
  }
}
