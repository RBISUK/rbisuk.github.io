// lib/email.ts
// Minimal adapter: swap the inside of sendMail() when you pick a provider.
// Supported via env: MAIL_FROM, MAIL_TO, MAIL_PROVIDER (optional), SENDGRID_KEY, RESEND_KEY, SMTP_*.

type MailPayload = { email: string; name?: string; message?: string; [k: string]: any };

export async function sendMail(data: MailPayload) {
  // DEV default: just log to server output
  if (!process.env.MAIL_PROVIDER) {
    console.log("📧 [DEV email] ->", JSON.stringify(data));
    return { ok: true, provider: "dev-log" };
  }

  // Example: Resend
  if (process.env.MAIL_PROVIDER === "resend" && process.env.RESEND_KEY) {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.RESEND_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        from: process.env.MAIL_FROM,
        to: [process.env.MAIL_TO],
        subject: `New submit from ${data.email}`,
        text: JSON.stringify(data, null, 2)
      })
    });
    return { ok: res.ok, provider: "resend", status: res.status };
  }

  // TODO: add SendGrid/Mailgun/SMTP branch if you choose
  console.warn("No supported MAIL_PROVIDER configured; falling back to log.");
  console.log("📧 [FALLBACK email] ->", JSON.stringify(data));
  return { ok: true, provider: "fallback-log" };
}
