export async function sendMail(to:string, subject:string, text:string){
  console.log("[email:stub]", { to, subject, preview: text.slice(0,160) });
  return { ok:true };
}
