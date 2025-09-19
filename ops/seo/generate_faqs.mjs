import fs from "fs";
import path from "path";

const ROOT = process.cwd();
const OUT_DIR = path.join(ROOT, "app", "(hdr)", "faq");

const slugify = s => s.toLowerCase().replace(/[^a-z0-9]+/g,"-").replace(/(^-|-$)/g,"");
const titleCase = s => s.replace(/\w\S*/g, w => w[0].toUpperCase()+w.slice(1));

const template = (q) => `export const metadata={title:"${titleCase(q)} | Housing Disrepair FAQ"};
export default function Page(){return(<main className="mx-auto max-w-3xl px-4 py-10">
<h1 className="text-3xl font-bold">${titleCase(q)}</h1>
<p className="mt-3 text-neutral-700">Short answer for tenants in plain English. Evidence-first guidance: photos/videos, timestamps, landlord messages. This page is informational, not legal advice.</p>
<section className="mt-6"><h2 className="text-xl font-semibold">What to do</h2><ol className="list-decimal pl-5">
<li>Log the issue via the 24/7 reporter.</li>
<li>Upload 2–4 photos/videos; our system timestamps & hashes them.</li>
<li>Keep a timeline of contacts and responses.</li></ol></section>
<section className="mt-6"><h2 className="text-xl font-semibold">When to escalate</h2><p>If repairs are ignored past the reasonable timeframe, you may escalate with your evidence pack.</p></section>
</main>); }`;

const keywords = fs.readFileSync(path.join(ROOT, "ops/seo/hdr_keywords.txt"), "utf8").split(/\r?\n/).map(s=>s.trim()).filter(Boolean);
fs.mkdirSync(OUT_DIR, { recursive: true });

let created = 0, updated = 0;
for (const q of keywords) {
  const slug = slugify(q);
  const file = path.join(OUT_DIR, `${slug}.tsx`);
  const content = template(q);
  if (!fs.existsSync(file)) { fs.writeFileSync(file, content); created++; }
  else {
    const old = fs.readFileSync(file, "utf8");
    if (old !== content) { fs.writeFileSync(file, content); updated++; }
  }
}
console.log(JSON.stringify({created, updated}));
