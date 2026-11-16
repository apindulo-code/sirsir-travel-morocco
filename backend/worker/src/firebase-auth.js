import { createRemoteJWKSet, jwtVerify } from "jose";

const FIREBASE_JWKS = createRemoteJWKSet(new URL(
  "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com",
));

export function assertFirebaseAccountActive(user, payload) {
  if (!user || user.localId !== payload.sub || user.disabled === true) {
    throw new Error("Firebase account is unavailable");
  }
  if (user.validSince != null) {
    const validSince = Number(user.validSince);
    if (!Number.isFinite(validSince) || payload.auth_time < validSince) {
      throw new Error("Firebase session has been revoked");
    }
  }
}

export async function verifyFirebaseToken(token, env, fetchImpl = fetch) {
  if (!env.FIREBASE_PROJECT_ID || !env.FIREBASE_WEB_API_KEY) {
    throw new Error("Firebase Worker configuration is incomplete");
  }

  const { payload } = await jwtVerify(token, FIREBASE_JWKS, {
    issuer: `https://securetoken.google.com/${env.FIREBASE_PROJECT_ID}`,
    audience: env.FIREBASE_PROJECT_ID,
    algorithms: ["RS256"],
    requiredClaims: ["exp", "iat", "sub", "auth_time"],
  });

  if (typeof payload.sub !== "string" || !payload.sub ||
      typeof payload.auth_time !== "number") {
    throw new Error("Invalid Firebase token claims");
  }

  const lookupUrl = new URL(
    "https://identitytoolkit.googleapis.com/v1/accounts:lookup",
  );
  lookupUrl.searchParams.set("key", env.FIREBASE_WEB_API_KEY);

  const response = await fetchImpl(lookupUrl, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ idToken: token }),
  });
  if (!response.ok) throw new Error("Firebase account status lookup failed");

  const data = await response.json();
  assertFirebaseAccountActive(data?.users?.[0], payload);
  return { uid: payload.sub };
}
