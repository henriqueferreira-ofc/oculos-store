import { createFileRoute } from "@tanstack/react-router";
import { createHmac, timingSafeEqual } from "crypto";

const COOKIE_NAME = "app_session";
const MAX_AGE = 60 * 60 * 8; // 8 hours

function sign(payload: string, secret: string) {
  return createHmac("sha256", secret).update(payload).digest("hex");
}

function makeToken(secret: string) {
  const exp = Math.floor(Date.now() / 1000) + MAX_AGE;
  const payload = `v1.${exp}`;
  return `${payload}.${sign(payload, secret)}`;
}

function verifyToken(token: string | undefined, secret: string): boolean {
  if (!token) return false;
  const parts = token.split(".");
  if (parts.length !== 3) return false;
  const [v, expStr, sig] = parts;
  const payload = `${v}.${expStr}`;
  const expected = sign(payload, secret);
  const a = Buffer.from(sig);
  const b = Buffer.from(expected);
  if (a.length !== b.length || !timingSafeEqual(a, b)) return false;
  const exp = Number(expStr);
  if (!Number.isFinite(exp) || exp * 1000 < Date.now()) return false;
  return true;
}

function getCookie(request: Request, name: string): string | undefined {
  const header = request.headers.get("cookie") ?? "";
  for (const part of header.split(";")) {
    const [k, ...rest] = part.trim().split("=");
    if (k === name) return rest.join("=");
  }
  return undefined;
}

function jsonResponse(body: unknown, init: ResponseInit = {}) {
  const headers = new Headers(init.headers);
  headers.set("Content-Type", "application/json");
  headers.set("Cache-Control", "no-store");
  return new Response(JSON.stringify(body), { ...init, headers });
}

export const Route = createFileRoute("/api/public/auth")({
  server: {
    handlers: {
      GET: async ({ request }) => {
        const secret = process.env.SESSION_SECRET;
        if (!secret) return jsonResponse({ authenticated: false }, { status: 500 });
        const token = getCookie(request, COOKIE_NAME);
        return jsonResponse({ authenticated: verifyToken(token, secret) });
      },
      POST: async ({ request }) => {
        const password = process.env.APP_PASSWORD;
        const secret = process.env.SESSION_SECRET;
        if (!password || !secret) {
          return jsonResponse({ error: "Server not configured" }, { status: 500 });
        }
        let body: { action?: string; password?: string } = {};
        try {
          body = await request.json();
        } catch {
          return jsonResponse({ error: "Invalid body" }, { status: 400 });
        }

        if (body.action === "logout") {
          const headers = new Headers();
          headers.append(
            "Set-Cookie",
            `${COOKIE_NAME}=; HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=0`,
          );
          headers.set("Content-Type", "application/json");
          return new Response(JSON.stringify({ ok: true }), { status: 200, headers });
        }

        const submitted = typeof body.password === "string" ? body.password : "";
        const a = Buffer.from(submitted);
        const b = Buffer.from(password);
        const ok = a.length === b.length && timingSafeEqual(a, b);
        if (!ok) {
          // small delay to slow brute force
          await new Promise((r) => setTimeout(r, 400));
          return jsonResponse({ error: "Senha incorreta" }, { status: 401 });
        }
        const token = makeToken(secret);
        const headers = new Headers();
        headers.append(
          "Set-Cookie",
          `${COOKIE_NAME}=${token}; HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=${MAX_AGE}`,
        );
        headers.set("Content-Type", "application/json");
        headers.set("Cache-Control", "no-store");
        return new Response(JSON.stringify({ ok: true }), { status: 200, headers });
      },
    },
  },
});
