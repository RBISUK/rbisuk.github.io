import Link from 'next/link';

export default function LegalHub() {
  const links = [
    { href: '/legal/privacy', label: 'Privacy Policy' },
    { href: '/legal/cookies', label: 'Cookie Policy' },
    { href: '/legal/terms', label: 'Terms of Service' },
    { href: '/legal/nda', label: 'Mutual NDA' },
    { href: '/legal/data-retention', label: 'Data Retention & Deletion Policy' },
    { href: '/legal/ai-ethics', label: 'AI Ethics Statement' },
    { href: '/legal/claims-policy', label: 'Claims & Testimonials Accuracy Policy' },
    { href: '/legal/dpa', label: 'Data Processing Addendum' }
  ];
  return (
    <div className="max-w-3xl mx-auto p-8 space-y-4">
      <h1 className="text-3xl font-bold mb-4">Legal Hub</h1>
      <ul className="list-disc pl-5 space-y-2">
        {links.map(link => (
          <li key={link.href}>
            <Link href={link.href} className="text-blue-600 hover:underline">
              {link.label}
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}
