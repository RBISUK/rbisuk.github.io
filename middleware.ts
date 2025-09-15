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
