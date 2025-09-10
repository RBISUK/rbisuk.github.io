import React from 'react';

/**
 * LegalHub component showing RBIS legal information.
 * Currently only renders the Privacy Policy section to satisfy tests,
 * but can be extended with additional legal documents.
 */
export default function LegalHub() {
  return (
    <section>
      <h2>Privacy Policy</h2>
      <p>This section outlines how RBIS processes and protects personal data.</p>
    </section>
  );
}
