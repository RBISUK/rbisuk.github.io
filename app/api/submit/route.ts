import { NextResponse } from "next/server";
import fs from "fs"; import path from "path";
import { sendMail } from "@/lib/email";
export const runtime = "nodejs";
const okEmail=(e:string)=>/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e||"");
const okUkMob=(m:string)=>/^(?:\+44|0)7\d{9}$/.test(m||"");
export async function POST(request:Request){
  let body:any; try{ body=await request.json(); }catch{ return NextResponse.json({ok:false,error:"invalid_json"},{status:400}); }
  if(body.website){ return NextResponse.json({ok:false,error:"spam"},{status:400}); } // honeypot
  const c=body.client||{}, i=body.issue||{};
  if(!c.title||!c.firstName||!c.lastName) return NextResponse.json({ok:false,error:"missing_name"},{status:400});
  if(!okUkMob(c.mobile)) return NextResponse.json({ok:false,error:"invalid_mobile"},{status:400});
  if(!okEmail(c.email))  return NextResponse.json({ok:false,error:"invalid_email"},{status:400});
  if(!i.type||!i.duration) return NextResponse.json({ok:false,error:"missing_issue"},{status:400});
  const line={ ts:new Date().toISOString(), product: body.product||"Housing Disrepair", client:c, issue:i, upsell:body.upsell||{} };
  const dir=path.join(process.cwd(),"logs"); fs.mkdirSync(dir,{recursive:true});
  fs.appendFileSync(path.join(dir,"form-submissions.ndjson"), JSON.stringify(line)+"\n");
  await sendMail(c.email,"RBIS — Intake received",`Thanks ${c.firstName}, we received your ${line.product} details at ${line.ts}.`);
  return NextResponse.json({ok:true});
}
