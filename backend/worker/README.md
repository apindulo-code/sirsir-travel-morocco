# SirSir Travel Morocco — Cloudflare Worker

This is a separate Workers-compatible implementation of the existing Express API. It preserves `POST /api/chat` and `GET /health`; the Express server remains untouched.

## Security design

- Firebase ID tokens are signature-verified with Google's Secure Token JWKS using `jose`.
- JWT issuer, audience, algorithm, expiry and required claims are checked.
- Firebase Identity Toolkit `accounts:lookup` confirms the account still exists, is not disabled, and its `validSince` timestamp does not revoke the token's `auth_time`. Failures deny access.
- Gemini is called only after authentication and input validation; the API key is stored as a Cloudflare secret and sent in the `x-goog-api-key` header.
- Browser CORS is restricted to one exact configured origin. Native requests without Origin are accepted but still require a Firebase ID token.
- Request body is limited to 8 KiB; message length to 2,000 characters; languages to ar/fr/en/es.
- Provider errors and bearer tokens are not logged.
- Two Cloudflare rate-limit bindings are included: an IP edge guard (20/minute) and a per-Firebase-UID chat guard (10/minute). Cloudflare counters are approximate and maintained separately per edge location; they are not strict global quotas. IP-based limits can affect users sharing a mobile carrier NAT, so the authenticated per-user limit is the primary chat control.

## Configuration

The repository includes `wrangler.toml`. Review it before deployment. The two positive-integer rate-limit namespace IDs must be unique within your Cloudflare account; change them if either is already used by another Worker. Cloudflare requires these IDs to be unique per account.

Browser access remains closed until `ALLOWED_ORIGIN` is set to the verified origin of the actual SirSir web app. Do not guess this value. Native Android requests without an Origin header remain supported.

Set secrets interactively; do not put values in source control:

```sh
npx wrangler secret put GEMINI_API_KEY
npx wrangler secret put FIREBASE_WEB_API_KEY
```

The Firebase Web API key is a client configuration identifier, not an Admin credential; it is required by Identity Toolkit `accounts:lookup`. Use the Web app key from Firebase project settings and apply appropriate API restrictions if supported.

## Local tests and configuration validation

```sh
cd backend/worker
npm install
npm test
npx wrangler deploy --dry-run
```

The tests inject authentication and Gemini dependencies so they do not need real Firebase tokens, Gemini credentials, or network access. Firebase account disabled/revocation boundary logic is tested separately. The Wrangler dry run compiles and validates the Worker without uploading or deploying it.

## Local development and deployment

After the configuration, verified namespace IDs, browser origin (if web access is required), and secrets are set:

```sh
npx wrangler dev
npx wrangler deploy
```

Deployment must only occur after reviewing the dry-run output and confirming the Cloudflare project configuration. The existing Express backend and Flutter client are not modified here. The Flutter `SIRSIR_AI_ENDPOINT` must be pointed at the Worker URL in a separate, tested change after deployment.

## Important limitations

Gemini Free Tier availability, model access and quotas depend on the Google AI Studio project and current terms. Do not send passwords, identity documents, payment details or sensitive booking data to the free-tier model. Cloudflare Workers Free has CPU and request limits; observe actual usage and error rates before production use.
