export const runtime = "nodejs";

type UploadBody = {
  filename: string;
  contentType?: string;
  data?: string; // base64 if you do direct uploads
};

function missing(msg: string) {
  return new Response(msg, { status: 501 });
}

export async function POST(req: Request) {
  const { AWS_REGION, AWS_S3_BUCKET, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY } = process.env;

  // If not configured, don't crash the build or the route — just return 501
  if (!AWS_REGION || !AWS_S3_BUCKET || !AWS_ACCESS_KEY_ID || !AWS_SECRET_ACCESS_KEY) {
    return missing("Uploads are not configured on this environment.");
  }

  // Dynamic import so Next.js can build even if the package isn't tree-shaken on other routes
  const [{ S3Client, PutObjectCommand }, { Buffer }] = await Promise.all([
    import("@aws-sdk/client-s3"),
    import("node:buffer"),
  ]);

  const body = (await req.json()) as UploadBody;
  if (!body?.filename) {
    return new Response("filename required", { status: 400 });
  }

  const client = new S3Client({ region: AWS_REGION, credentials: {
    accessKeyId: AWS_ACCESS_KEY_ID!,
    secretAccessKey: AWS_SECRET_ACCESS_KEY!,
  }});

  // Minimal placeholder write (switch to signed-URL flow later if you prefer)
  const Key = body.filename;
  const ContentType = body.contentType || "application/octet-stream";
  const data = body.data ? Buffer.from(body.data, "base64") : Buffer.from("");

  await client.send(new PutObjectCommand({
    Bucket: AWS_S3_BUCKET,
    Key,
    Body: data,
    ContentType,
  }));

  return Response.json({ ok: true, key: Key });
}
