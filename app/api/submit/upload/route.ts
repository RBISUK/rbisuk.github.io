import { NextResponse } from "next/server";
import fs from "fs";
import path from "path";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import mime from "mime";

export const runtime = "nodejs";

function publicS3Url(bucket: string, region: string, key: string) {
  const base = process.env.S3_PUBLIC_URL;
  if (base) return `${base.replace(/\/+$/,"")}/${key}`;
  return `https://${bucket}.s3.${region}.amazonaws.com/${key}`;
}

export async function POST(req: Request) {
  const ct = req.headers.get("content-type") || "";
  if (!ct.startsWith("multipart/form-data")) {
    return NextResponse.json({ ok:false, error:"invalid_content_type" }, { status:400 });
  }
  const form = await req.formData();
  const f = form.get("file") as File | null;
  if (!f) return NextResponse.json({ ok:false, error:"no_file" }, { status:400 });
  if (f.size > 15 * 1024 * 1024) return NextResponse.json({ ok:false, error:"too_large" }, { status:413 });

  // allow images & video only (dev safe)
  const type = f.type || "";
  if (!/^image\/|^video\//.test(type)) {
    return NextResponse.json({ ok:false, error:"unsupported_type" }, { status:415 });
  }

  const buf = Buffer.from(await f.arrayBuffer());
  const orig = f.name || "upload.bin";
  const ext = (orig.includes(".") ? orig.split(".").pop() : "") || mime.getExtension(type) || "bin";
  const key = `evidence/${Date.now()}_${Math.random().toString(36).slice(2)}.${ext}`;

  const bucket = process.env.S3_BUCKET;
  const region = process.env.AWS_REGION || "eu-west-2";
  if (bucket && process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
    const s3 = new S3Client({ region });
    const put = new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      Body: buf,
      ContentType: type || mime.getType(ext) || "application/octet-stream",
      ...(process.env.S3_ACL_PUBLIC ? { ACL: "public-read" } : {}),
    });
    await s3.send(put);
    return NextResponse.json({ ok:true, url: publicS3Url(bucket, region, key) });
  }

  // fallback: local dev
  const uploads = path.join(process.cwd(), "public", "uploads");
  fs.mkdirSync(uploads, { recursive: true });
  fs.writeFileSync(path.join(uploads, key.replace(/^evidence\//,"")), buf);
  return NextResponse.json({ ok:true, url: `/uploads/${key.replace(/^evidence\//,"")}` });
}
