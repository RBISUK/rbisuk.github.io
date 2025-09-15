// Simple split & pages smoke test.
// Assumes you already ran: next build && next start -p 4000
// Node 18+ has global fetch.

const base = process.env.BASE_URL || 'http://127.0.0.1:4000';

const checks = [
  { path: '/',      expect: /RBIS\s+Intelligence|RBIS UK Website|RBIS\s+—/i, label: 'Root → shows RBIS' },
  { path: '/main',  expect: /RBIS\s+Intelligence|RBIS\s+—/i,                   label: 'RBIS main' },
  { path: '/hdr',   expect: /Housing\s+Disrepair|Claim[-–]Fix[-–]AI|HDR/i,     label: 'HDR funnel' },

  // add a few “must not 404” pages (adjust if you renamed)
  { path: '/hdr/pricing',     expect: /(Pricing|Prices|Cost)/i,                label: 'HDR → pricing' },
  { path: '/hdr/what-it-does',expect: /(How it works|What it does)/i,          label: 'HDR → what-it-does' },
  { path: '/main/trust',      expect: /(Trust|Compliance|Ethics)/i,            label: 'RBIS → trust' },
  { path: '/main/value',      expect: /(Value|Outcomes|Impact)/i,              label: 'RBIS → value' },
  { path: '/main/dashboards', expect: /(Dashboard|Insights)/i,                 label: 'RBIS → dashboards' },
];

function green(s){ return `\x1b[32m${s}\x1b[0m`; }
function red(s){   return `\x1b[31m${s}\x1b[0m`; }
function gray(s){  return `\x1b[90m${s}\x1b[0m`; }

async function hit(path) {
  const url = base + path;
  const res = await fetch(url, { redirect: 'follow' });
  const text = await res.text();
  return { status: res.status, text };
}

(async () => {
  console.log(gray(`Smoke @ ${base}`));
  let failed = 0;

  for (const c of checks) {
    try {
      const { status, text } = await hit(c.path);
      const okStatus = (status >= 200 && status < 400); // allow redirects
      const hasMarker = c.expect.test(text);
      if (okStatus && hasMarker) {
        console.log(`✅ ${c.label} (${c.path})`);
      } else {
        failed++;
        console.log(`❌ ${c.label} (${c.path}) — status=${status}, marker=${hasMarker}`);
      }
    } catch (e) {
      failed++;
      console.log(`❌ ${c.label} (${c.path}) — ${e.message}`);
    }
  }

  if (failed) {
    console.log(red(`\n${failed} check(s) failed`));
    process.exit(1);
  } else {
    console.log(green(`\nAll checks passed ✔`));
  }
})();
