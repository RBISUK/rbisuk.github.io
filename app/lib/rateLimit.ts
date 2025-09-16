const BUCKET: Map<string, {count:number; reset:number}> = new Map();

export function rateLimit(req: Request, opts = { windowMs: 60_000, max: 30 }) {
  const ip = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim()
        || (globalThis as any).__DEV_IP__ || "local";
  const now = Date.now();
  const rec = BUCKET.get(ip);
  if (!rec || rec.reset < now) {
    BUCKET.set(ip, { count: 1, reset: now + opts.windowMs });
    return { ok: true };
  }
  if (rec.count >= opts.max) return { ok: false, retryAfter: Math.ceil((rec.reset - now)/1000) };
  rec.count++;
  return { ok: true };
}
