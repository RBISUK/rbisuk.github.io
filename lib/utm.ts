export function readUTM() {
  if (typeof window === "undefined") return {};
  const p = new URLSearchParams(window.location.search);
  const keys = ["utm_source","utm_medium","utm_campaign","utm_term","utm_content"];
  const out: Record<string,string> = {};
  for (const k of keys) { const v = p.get(k); if (v) out[k]=v; }
  return out;
}
