<<<<<<< HEAD
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(req: NextRequest) {
  const host = req.headers.get('host') ?? '';
  const url = req.nextUrl;

  if (host.startsWith('hdr.')) {
    if (!url.pathname.startsWith('/hdr')) {
      const to = url.clone();
      to.pathname = '/hdr' + (url.pathname === '/' ? '' : url.pathname);
      return NextResponse.rewrite(to);
    }
    return NextResponse.next();
  }

  if (!url.pathname.startsWith('/main')) {
    const to = url.clone();
    to.pathname = '/main' + (url.pathname === '/' ? '' : url.pathname);
    return NextResponse.rewrite(to);
  }
  return NextResponse.next();
}
export const config = { matcher: ['/:path*'] };
=======
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
>>>>>>> e9bbbeda81632fe34d9beba4ebacffe242ef73ef
