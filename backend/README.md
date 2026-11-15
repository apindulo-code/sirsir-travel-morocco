# SirSir AI backend

This service implements the Flutter contract at `POST /api/chat`. It keeps the Gemini key on the server and verifies Firebase ID tokens before generating a response.

## Environment

Copy `.env.example` to `.env` for local development and set:

- `GEMINI_API_KEY`: secret Gemini key; server-side only.
- `GEMINI_MODEL=gemini-2.0-flash`
- `ALLOWED_ORIGIN`: one exact browser origin, e.g. `https://app.example.com`. Native Flutter requests without an Origin header are accepted but still require Firebase authentication.
- `PORT=8080`
- `GEMINI_TIMEOUT_MS=30000`

Never commit `.env`, paste secrets into GitHub source, or pass the Gemini key through Flutter `--dart-define`.

## Local run

Requires Node.js 22+ and Firebase Application Default Credentials for the same Firebase project.

```sh
cd backend
cp .env.example .env
# Edit .env locally; do not commit it.
npm install
gcloud auth application-default login
export GOOGLE_CLOUD_PROJECT=sirsir-travel-morocco
npm start
```

The backend uses Firebase Admin Application Default Credentials. On Cloud Run, attach a dedicated runtime service account with the minimum Firebase Authentication token-verification permissions; do not upload a service-account JSON key. Grant outbound access to the Gemini API.

## Deploy

Build and deploy the container to Cloud Run or another HTTPS container platform. Configure the five environment variables in the hosting platform's secret/environment settings; store `GEMINI_API_KEY` in the platform secret manager, not as a plaintext checked-in file. Bind a dedicated service account to the runtime and require HTTPS. Set the resulting HTTPS `/api/chat` URL as Flutter `SIRSIR_AI_ENDPOINT` when building the app.

## Security controls

- Firebase ID token verification with revocation checking.
- Exact browser-origin allowlist; mobile requests still require auth.
- JSON body limit, 2,000-character prompt limit and language allowlist (ar/fr/en/es).
- Per-IP rate limit (20 requests per 15 minutes), Helmet headers and bounded upstream timeout.
- No request body, bearer token, API key or provider URL is written to logs.

The default in-memory rate limiter is per process. Before public scale-out, use a shared Redis-backed limiter and add per-Firebase-user quotas, monitoring, billing alerts and abuse controls. Review current Google AI service terms and model availability before production deployment.
