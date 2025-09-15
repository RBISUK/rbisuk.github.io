import Link from "next/link";
export default function NotFoundHDR(){
  return (
    <div className="prose">
      <h1>HDR page not found</h1>
      <p>Go back to <Link href="/hdr">HDR home</Link>.</p>
    </div>
  );
}
