#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "❌ Error on line $LINENO. Check rbis_log.txt for details." >&2' ERR

log() { printf "%b\n" "$*"; }
write_file () { local path="$1" content="$2"; mkdir -p "$(dirname "$path")"; printf "%s" "$content" > "$path"; log "✅ wrote $path"; }

# sanity checks
command -v git >/dev/null || { echo "❌ git not found"; exit 1; }
command -v node >/dev/null || { echo "❌ node not found"; exit 1; }
[[ -f package.json ]] || { echo "❌ Run from your Next.js project root (package.json not found)"; exit 1; }

# detect router
HAS_APP=0; HAS_PAGES=0
[[ -d app ]] && HAS_APP=1
[[ -d pages ]] && HAS_PAGES=1
if [[ $HAS_APP -eq 0 && $HAS_PAGES -eq 0 ]]; then mkdir -p app; HAS_APP=1; fi

# git branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD || echo main)
TARGET_BRANCH="feature/rbis-site-upgrade"
if git show-ref --verify --quiet "refs/heads/$TARGET_BRANCH"; then git checkout "$TARGET_BRANCH"; else git checkout -b "$TARGET_BRANCH"; fi

# dirs
mkdir -p app/config components app/products
mkdir -p app/products/{claim-fix-ai,omniassist,dashboard,nextusone,websites,pact-ledger}

# config
write_file "app/config/rbisContent.ts" 'export const rbisContent={hero:{title:"RBIS: Behavioural & Intelligence Services",subtitle:"Live robots. AI at the edge. Compliance-first systems. No static competitor can keep up.",ctas:[{label:"Book a Demo",href:"/contact"},{label:"Explore the RBIS Suite",href:"/products"}]},express:{priceSetup:"£4,995 setup",priceMonthly:"£995/month",bullets:["24-hour rollout — branded, integrated, live tomorrow","AI-native funnel — not a static form","SEO-AI optimisation — rank + convert, regulator-safe","Compliance armour — GDPR, ASA, FCA, SRA overlays","Evidence-first lead gen — packs, SLAs, timelines","Ongoing updates & support"],lockIn:"Lock in this price as an RBIS Express early partner"},products:[{name:"Claim-Fix-AI",tagline:"Turn tenant complaints into audit-ready cases",href:"/products/claim-fix-ai"},{name:"OmniAssist",tagline:"AI colleague who never cuts corners",href:"/products/omniassist"},{name:"RBIS Dashboard",tagline:"Ops lit up, not buried in spreadsheets",href:"/products/dashboard"},{name:"NextusOne CRM",tagline:"The CRM that speaks regulator + client",href:"/products/nextusone"},{name:"Custom Sites & SEO-AI",tagline:"Websites & SEO that survive audits",href:"/products/websites"},{name:"PACT Ledger",tagline:"Every promise made, kept, or called to account",href:"/products/pact-ledger"}],why:[{icon:"🤖",title:"Live Robots",body:"Conversational AI, instant evidence, 24/7"},{icon:"🛡",title:"Compliance Armour",body:"Audit-ready by design (FCA, SRA, GDPR, ASA)"},{icon:"⚡",title:"Licensable Speed",body:"White-label rollouts in under 24 hours"}],trust:["Housing provider cut SLA breaches by 70%","Law firm onboarded 200+ disrepair claims with zero rejected evidence","Tenant group generated a full Ombudsman pack in 5 minutes"]};'
write_file "app/config/flags.ts" 'export const flags={rbis:{expressOffer:true,homeMobileFlow:true,productCarousel:true,stickyCTA:true}};'

# components
write_file "components/ProductCard.tsx" 'import Link from "next/link";export default function ProductCard({name,tagline,href}:{name:string;tagline:string;href:string}){return(<Link href={href} className="block rounded-lg border border-neutral-200 hover:shadow-md transition p-5 bg-white focus:outline-none focus:ring-2 focus:ring-black/40"><h3 className="text-lg font-semibold">{name}</h3><p className="text-sm text-neutral-600 mt-1">{tagline}</p><span className="inline-block mt-3 text-sm font-medium underline">Learn more</span></Link>);}'
write_file "components/ExpressPricing.tsx" 'export default function ExpressPricing({content}:{content:any}){const{priceSetup,priceMonthly,bullets,lockIn}=content;return(<section aria-labelledby="express-title" className="mx-auto max-w-3xl sm:max-w-5xl px-4 py-12"><h2 id="express-title" className="text-2xl sm:text-3xl font-bold text-center">One Price. One Day. One System Nobody Else Can Match.</h2><div className="mt-6 rounded-xl border border-neutral-200 shadow-sm bg-white"><div className="p-6 sm:p-8 text-center"><div className="text-3xl font-bold">{priceSetup}</div><div className="mt-1 text-neutral-600">{priceMonthly}</div><ul className="mt-6 space-y-2 text-left">{bullets.map((b:string,i:number)=>(<li key={i} className="flex items-start gap-2"><span aria-hidden>✅</span><span className="text-sm sm:text-base">{b}</span></li>))}</ul><div className="mt-4 text-sm italic text-amber-700">{lockIn}</div><div className="mt-6"><a href="/contact" className="inline-flex w-full sm:w-auto justify-center rounded-lg px-5 py-3 text-white bg-black hover:bg-neutral-800 focus:outline-none focus:ring-2 focus:ring-black/40">Book My 24h Build</a></div></div></div></section>);}'
write_file "components/StickyCTA.tsx" 'export default function StickyCTA(){return(<div className="fixed inset-x-0 bottom-0 z-40 border-t border-neutral-200 bg-white/95 backdrop-blur supports-[backdrop-filter]:bg-white/70" role="region" aria-label="Quick actions"><div className="mx-auto max-w-5xl px-4 py-3 flex items-center justify-between gap-3"><span className="text-sm font-medium">Ready to see RBIS in action?</span><a href="/contact" className="rounded-lg px-4 py-2 text-white bg-black hover:bg-neutral-800 focus:outline-none focus:ring-2 focus:ring-black/40">Book a Demo</a></div></div>);}'
# pages (App Router by default)
if [[ $HAS_APP -eq 1 ]]; then
write_file "app/page.tsx" 'import { rbisContent } from "./config/rbisContent";import { flags } from "./config/flags";import ProductCard from "@/components/ProductCard";import ExpressPricing from "@/components/ExpressPricing";import StickyCTA from "@/components/StickyCTA";export default function Home(){const c=rbisContent;return(<main><section className="px-4 pt-10 pb-8 mx-auto max-w-6xl"><h1 className="text-4xl md:text-6xl font-bold">{c.hero.title}</h1><p className="mt-3 text-neutral-700 max-w-2xl">{c.hero.subtitle}</p><div className="mt-6 flex flex-col sm:flex-row gap-3" role="group" aria-label="Primary actions">{c.hero.ctas.map((cta:any)=>(<a key={cta.href} href={cta.href} className="rounded-lg px-5 py-3 text-white bg-black hover:bg-neutral-800 text-center focus:outline-none focus:ring-2 focus:ring-black/40">{cta.label}</a>))}</div></section><section className="px-4 py-8 mx-auto max-w-6xl"><h2 className="text-2xl md:text-3xl font-bold">The RBIS Suite: One Ecosystem, Infinite Scale</h2><div className="mt-6 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">{c.products.map((p:any)=><ProductCard key={p.name} {...p}/>)}</div></section>{flags.rbis.expressOffer&&<ExpressPricing content={c.express}/>}<section className="px-4 py-8 mx-auto max-w-6xl"><h2 className="text-2xl md:text-3xl font-bold">Why Nobody Can Keep Up</h2><div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">{c.why.map((w:any,i:number)=>(<div key={i} className="rounded-lg border border-neutral-200 p-5 bg-white"><div className="text-3xl">{w.icon}</div><h3 className="mt-2 font-semibold">{w.title}</h3><p className="text-sm text-neutral-700 mt-1">{w.body}</p></div>))}</div></section><section className="px-4 pb-24 mx-auto max-w-6xl"><h2 className="text-2xl md:text-3xl font-bold">Audit-Proof. Regulator-Ready. Client-Approved.</h2><ul className="mt-4 space-y-2">{c.trust.map((t:any,i:number)=>(<li key={i} className="text-sm text-neutral-700">• {t}</li>))}</ul></section>{flags.rbis.stickyCTA&&<StickyCTA/>}</main>);}'
write_file "app/products/page.tsx" 'import Link from "next/link";import { rbisContent } from "../config/rbisContent";export default function Products(){return(<main className="mx-auto max-w-4xl px-4 py-12"><h1 className="text-3xl font-bold">RBIS Product Suite</h1><ul className="mt-6 space-y-3">{rbisContent.products.map((p:any)=>(<li key={p.href}><Link href={p.href} className="underline">{p.name}</Link><span className="text-neutral-600"> — {p.tagline}</span></li>))}</ul></main>);}'
for slug in claim-fix-ai omniassist dashboard nextusone websites pact-ledger; do write_file "app/products/$slug/page.tsx" "export default function Page(){return(<main className='mx-auto max-w-3xl px-4 py-12'><h1 className='text-3xl font-bold'>${slug//-/ }</h1><p className='mt-3 text-neutral-700'>Stub page — content coming soon.</p></main>);}"; done
else
mkdir -p pages pages/products
write_file "pages/index.tsx" 'import { rbisContent } from "../app/config/rbisContent";import ProductCard from "../components/ProductCard";import ExpressPricing from "../components/ExpressPricing";export default function Home(){const c=rbisContent;return(<main><section className="px-4 pt-10 pb-8 mx-auto max-w-6xl"><h1 className="text-4xl md:text-6xl font-bold">{c.hero.title}</h1><p className="mt-3 text-neutral-700 max-w-2xl">{c.hero.subtitle}</p><div className="mt-6 flex flex-col sm:flex-row gap-3" role="group" aria-label="Primary actions">{c.hero.ctas.map((cta:any)=>(<a key={cta.href} href={cta.href} className="rounded-lg px-5 py-3 text-white bg-black hover:bg-neutral-800 text-center">{cta.label}</a>))}</div></section><section className="px-4 py-8 mx-auto max-w-6xl"><h2 className="text-2xl md:text-3xl font-bold">The RBIS Suite: One Ecosystem, Infinite Scale</h2><div className="mt-6 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">{c.products.map((p:any)=><ProductCard key={p.name} {...p}/>)}</div></section><ExpressPricing content={c.express}/></main>);}'
write_file "pages/products/index.tsx" "export default ()=> <main className='p-10'><h1 className='text-3xl font-bold'>RBIS Product Suite</h1></main>"
fi

# env example
printf "%s\n" "NEXT_PUBLIC_ENV=staging" > .env.staging.example

git add -A || true
git commit -m "feat(rbis): drop-in components, config, flags, pages" || true
log "🎉 Done. Now run: npm install && npm run dev"
