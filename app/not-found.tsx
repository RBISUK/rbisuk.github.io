import Link from "next/link";
export default function NotFound(){
  return (
    <div className="prose">
      <h1>Not found</h1>
      <p>Try <Link href="/hdr">HDR</Link> or <Link href="/main">RBIS main</Link>.</p>
    </div>
  );
}
