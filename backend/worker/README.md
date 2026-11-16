# SirSir Travel Morocco — Cloudflare Worker

This is a separate Workers-compatible implementation of the existing Express API. It preserves `POST /api/chat` and `GET /health`; the Express server remains untouched.

## Security design

- Firebase ID tokens are signature-verified with Google's Secure Token JWKS using `jose`.
- JWT issuer, audience, algorithm, expiry and required claims are checked.
- Firebase Identity Toolkit `accounts:lookup` confirms the account still exists, is not disabled, and its `validSince` timestamp does not revoke the token's `auth_time`. Failures deny access.
- Gemini is called only after Firebase verification and request validation.
- Gemini key is sent in the `x-goog-api-key` header and must be a Cloudflare secret.
- Browser CORS is restricted to one exact configured origin. Native requests without Origin are accepted but still require a Firebase ID token.
- Request body is limited to 8 KiB; message length to 2,000 characters; languages to ar/fr/en/es.
- Provider errors and bearer tokens are not logged.

## Configuration

Copy `wrangler.toml.example` to `wrangler.toml` and replace the browser origin with the actual SirSir web origin. Configure a Cloudflare Rate Limiting binding named `CHAT_LIMITER`; its example is 7 requests per 5 minutes per client IP, approximately preserving the previous 20-per-15-minute ceiling. Cloudflare counters are location-scoped, so this is an edge abuse guard rather than a global quota. Add per-Firebase-user quotas before broad public launch.

Set secrets interactively; do not put values in source control:

```sh
npx wrangler secret put GEMINI_API_KEY
npx wrangler secret put FIREBASE_WEB_API_KEY
```

The Firebase Web API key is a client configuration identifier, not an Admin credential; it is required by Identity Toolkit accounts:lookup. Use the Web app key from Firebase project settings and apply appropriate API restrictions if supported.

## Local tests

```sh
cd backend/worker
npm install
npm test
```

The tests inject authentication and Gemini dependencies so they do not need real Firebase tokens, Gemini credentials, or network access.

## Local development and deployment

After the configuration and secrets are set:

```sh
npx wrangler dev
# deploy only after reviewing the test results and explicitly approving deployment
npx wrangler deploy
```

No deployment is performed by these files or tests. The existing Express backend and Flutter client are not modified here. The Flutter `SIRSIR_AI_ENDPOINT` must be pointed at the Worker URL in a separate, tested change after deployment.

## Important limitations

Gemini Free Tier availability, model access and quotas depend on the Google AI Studio project and current terms. Do not send passwords, identity documents, payment details or sensitive booking data to the free-tier model. Cloudflare Workers Free has CPU and request limits; observe actual usage and error rates before production use.
