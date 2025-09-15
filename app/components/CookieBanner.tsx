"use client";
import { useEffect, useState } from "react";

export default function CookieBanner() {
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const consent = typeof window !== "undefined" ? localStorage.getItem("cookie-consent") : "accepted";
    if (!consent) setVisible(true);
  }, []);
  function accept() {
    localStorage.setItem("cookie-consent", "accepted");
    setVisible(false);
  }
  if (!visible) return null;
  return (
    <div className="fixed bottom-0 inset-x-0 bg-gray-900 text-white p-4 z-50 flex flex-col md:flex-row items-center justify-between">
      <p className="text-sm mb-2 md:mb-0">
        We use only necessary cookies. See our{" "}
        <a href="/legal/cookies" className="underline text-blue-300">Cookie Policy</a>.
      </p>
      <button onClick={accept} className="ml-4 bg-blue-600 text-white px-4 py-2 rounded">Accept</button>
    </div>
  );
}
