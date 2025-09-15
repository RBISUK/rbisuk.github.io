import Link from "next/link";
export default function Choose(){
  return (
    <section className="space-y-6">
      <h1 className="text-3xl font-bold">RBIS — Choose a site</h1>
      <ul className="space-y-2">
        <li><Link className="underline" href="/hdr">HDR: Claim-Fix-AI funnel</Link></li>
        <li><Link className="underline" href="/main">RBIS Intelligence (showcase)</Link></li>
      </ul>
    </section>
  );
}
