import Link from 'next/link';

export default function Footer() {
  return (
    <footer className="bg-gray-800 text-gray-200 py-8" id="legal">
      <div className="max-w-7xl mx-auto px-4">
        <h2 className="text-xl font-semibold mb-4">Legal Hub</h2>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 text-sm">
          <Link href="/legal/privacy" className="hover:underline">Privacy Policy</Link>
          <Link href="/legal/cookies" className="hover:underline">Cookie Policy</Link>
          <Link href="/legal/terms" className="hover:underline">Terms of Service</Link>
          <Link href="/legal/nda" className="hover:underline">Mutual NDA</Link>
          <Link href="/legal/data-retention" className="hover:underline">Data Retention & Deletion Policy</Link>
          <Link href="/legal/ai-ethics" className="hover:underline">AI Ethics Statement</Link>
          <Link href="/legal/claims-policy" className="hover:underline">Claims & Testimonials Accuracy Policy</Link>
          <Link href="/legal/dpa" className="hover:underline">Data Processing Addendum</Link>
        </div>
        <p className="mt-4 text-xs text-gray-400">© {new Date().getFullYear()} RBIS UK. All rights reserved.</p>
      </div>
    </footer>
  );
}
