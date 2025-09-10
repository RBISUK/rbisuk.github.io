import React, { useState } from "react";

// Organisation constants
export const ORG_EMAIL = "contact@RBISIntelligence";
export const ORG_ADDRESS = "PO Box, Bournemouth, Dorset, BH2 5RR, England";
export const ORG_WEBSITE = "https://rbisintelligence.com";
export const ORG_REGION = "United Kingdom";
export const ORG_STORAGE_PROVIDER = "AWS (London, UK)";
export const PROCESSORS = ["Formspree", "Google Analytics"];

export function RBISCookieGate() {
  const [consent, setConsent] = useState(() => localStorage.getItem("rbis_cookie_consent") === "true");
  if (consent) return null;
  return (
    <div className="cookie-gate">
      <p>We use cookies for analytics.</p>
      <button onClick={() => { localStorage.setItem("rbis_cookie_consent","true"); setConsent(true); }}>Allow</button>
    </div>
  );
}

export function RBISFooterLegal() {
  return (
    <nav className="legal-links">
      <a href="/legal#privacy">Privacy</a>
      <a href="/legal#terms">Terms</a>
      <a href="/legal#cookies">Cookies</a>
      <a href="/legal#security">Security</a>
    </nav>
  );
}

export function RBISConsentSnippet({ requireNDA, onNDAToggle }) {
  const [nda, setNda] = useState(false);
  return (
    <div className="consent-snippet">
      <label className="check-line">
        <input type="checkbox" required /> I agree to the <a href="/legal#privacy" target="_blank" rel="noopener noreferrer">Privacy Policy</a> and <a href="/legal#terms" target="_blank" rel="noopener noreferrer">Terms</a>.
      </label>
      {requireNDA && (
        <label className="check-line" style={{marginTop: "8px"}}>
          <input type="checkbox" checked={nda} onChange={e => { setNda(e.target.checked); onNDAToggle?.(e.target.checked); }} /> Request mutual NDA
        </label>
      )}
    </div>
  );
}

export default function LegalHub() {
  return (
    <div className="legal-hub">
      <h1>Legal Hub</h1>
      <section id="privacy">
        <h2>Privacy Policy</h2>
        <p>Detailed information on how we handle personal data and your rights.</p>
      </section>
      <section id="terms">
        <h2>Terms of Service</h2>
        <p>Terms and conditions for using our services and website.</p>
      </section>
      <section id="cookies">
        <h2>Cookie Policy</h2>
        <p>Explanation of cookies and similar technologies we employ.</p>
      </section>
      <section id="security">
        <h2>Security Statement</h2>
        <p>Overview of our security practices and data storage policies.</p>
      </section>
    </div>
  );
}

