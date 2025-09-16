"use client";
import { useEffect } from "react";
import { usePathname } from "next/navigation";

export default function ScrollManager() {
  const path = usePathname();
  useEffect(() => {
    // scroll to top on route change
    window.scrollTo({ top: 0, behavior: "instant" as ScrollBehavior });
  }, [path]);
  return null;
}
