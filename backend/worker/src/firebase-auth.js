import { createRemoteJWKSet, jwtVerify } from "jose";

const FIREBASE_JWKS = createRemoteJWKSet(new URL(
  "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com",
));

const INVALID_TOKEN_CODES = new Set([
  "INVALID_ID_TOKEN",
  "USER_DISABLED",
  "USER_NOT_FOUND",
  "TOKEN_EXPIRED",
]);

export class FirebaseAuthError extends Error {
  constructor(message) {
    super(message);
    this.name = "FirebaseAuthError";
  }
}

export class FirebaseServiceError extends Error {
  constructor(message, options = {}) {
    super(message, options);
    this.name = "FirebaseServiceError";
  }
}

export function assertFirebaseAccountActive(user, payload) {
  if (!user || user.localId !== payload.sub || user.disabled === true) {
    throw new FirebaseAuthError("Firebase account is unavailable");
  }
  if (user.validSince != null) {
    const validSince = Number(user.validSince);
    if (!Number.isFinite(validSince) || payload.auth_time < validSince) {
      throw new FirebaseAuthError("Firebase session has been revoked");
    }
  }
}

export async function verifyFirebaseToken(token, env, fetchImpl = fetch, verifyJwt = jwtVerify) {
  if (!env.FIREBASE_PROJECT_ID || !env.FIREBASE_WEB_API_KEY) {
    throw new FirebaseServiceError("Firebase Worker configuration is incomplete");
  }

  let payload;
  try {
    ({ payload } = await verifyJwt(token, FIREBASE_JWKS, {
      issuer: `https://securetoken.google.com/${env.FIREBASE_PROJECT_ID}`,
      audience: env.FIREBASE_PROJECT_ID,
      algorithms: ["RS256"],
      requiredClaims: ["exp", "iat", "sub", "auth_time"],
    }));
  } catch (error) {
    if (typeof error?.code === "string" &&
        (error.code.startsWith("ERR_JWT_") || error.code.startsWith("ERR_JWS_"))) {
      throw new FirebaseAuthError("Firebase ID token is invalid");
    }
    throw new FirebaseServiceError("Firebase signing-key service is unavailable", { cause: error });
  }

  if (typeof payload.sub !== "string" || !payload.sub ||
      typeof payload.auth_time !== "number") {
    throw new FirebaseAuthError("Invalid Firebase token claims");
  }

  return lookupFirebaseAccount(token, env, fetchImpl, payload);
}

export async function lookupFirebaseAccount(token, env, fetchImpl, payload) {
  const lookupUrl = new URL(
    "https://identitytoolkit.googleapis.com/v1/accounts:lookup",
  );
  lookupUrl.searchParams.set("key", env.FIREBASE_WEB_API_KEY);

  const configuredTimeout = Number(env.FIREBASE_LOOKUP_TIMEOUT_MS);
  const timeoutMs = Math.min(
    Math.max(Number.isFinite(configuredTimeout) && configuredTimeout > 0
      ? configuredTimeout : 8000, 1000),
    15000,
  );
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  try {
    let response;
    try {
      response = await fetchImpl(lookupUrl, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ idToken: token }),
        signal: controller.signal,
      });
    } catch (error) {
      if (controller.signal.aborted) {
        throw new FirebaseServiceError("Firebase account lookup timed out", { cause: error });
      }
      throw new FirebaseServiceError("Firebase account lookup is unavailable", { cause: error });
    }

    if (!response.ok) {
      let firebaseErrorCode;
      try {
        const errorBody = await response.json();
        firebaseErrorCode = errorBody?.error?.message;
      } catch {
        // A malformed error body is a dependency failure, not proof of a bad token.
      }
      if (INVALID_TOKEN_CODES.has(firebaseErrorCode)) {
        throw new FirebaseAuthError("Firebase account lookup rejected the token");
      }
      throw new FirebaseServiceError(
        `Firebase account lookup returned HTTP ${response.status}`,
      );
    }

    let data;
    try {
      data = await response.json();
    } catch (error) {
      throw new FirebaseServiceError("Firebase account lookup returned invalid JSON", { cause: error });
    }
    assertFirebaseAccountActive(data?.users?.[0], payload);
    return { uid: payload.sub };
  } finally {
    clearTimeout(timer);
  }
}
