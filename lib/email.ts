export async function sendMail(_: {to:string;subject:string;text:string}) {
  console.log("[email:stub] would send:", _.subject);
  return { ok: true };
}
