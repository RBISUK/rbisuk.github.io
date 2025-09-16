'use client';

import Script from "next/script";
import { usePathname } from "next/navigation";
import { useEffect } from "react";
import { GA_TRACKING_ID, pageview } from "@/lib/gtag";

export default function GA() {
  const pathname = usePathname();

  useEffect(() => {
    if (GA_TRACKING_ID && pathname) pageview(pathname);
  }, [pathname]);

  if (!GA_TRACKING_ID) return null;

  return (
    <>
      <Script
        strategy="afterInteractive"
        src={`https://www.googletagmanager.com/gtag/js?id=${GA_TRACKING_ID}`}
      />
      <Script id="ga-init" strategy="afterInteractive">
        {`
          window.dataLayer = window.dataLayer || [];
          function gtag(){dataLayer.push(arguments);}
          gtag('js', new Date());
          gtag('config', '${GA_TRACKING_ID}', { page_path: window.location.pathname });
        `}
      </Script>
    </>
  );
}
