import { NextResponse } from "next/server";
export function middleware(req: Request) {
  const res = NextResponse.next();
  res.headers.set("X-Frame-Options","DENY");
  res.headers.set("X-Content-Type-Options","nosniff");
  res.headers.set("Referrer-Policy","no-referrer-when-downgrade");
  res.headers.set("Permissions-Policy","geolocation=(), microphone=(), camera=()");
  // Strict-Transport-Security is set by your reverse proxy/CDN in prod
  return res;
}
export const config = { matcher: ["/:path*"] };
