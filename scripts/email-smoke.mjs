import nodemailer from "nodemailer";

const host = process.env.SMTP_HOST;
if (!host) {
  console.error("No SMTP_HOST set — fill .env.local first.");
  process.exit(1);
}
const port = Number(process.env.SMTP_PORT || "587");
const user = process.env.SMTP_USER || "";
const pass = process.env.SMTP_PASS || "";
const from = process.env.SMTP_FROM || user;
const to = process.env.TEST_TO || user;

const t = nodemailer.createTransport({ host, port, secure: port===465, auth: { user, pass } });
await t.sendMail({ from, to, subject: "RBIS Smoke Email", text: "This is a test from RBIS." });
console.log("✅ Email smoke sent to", to);
