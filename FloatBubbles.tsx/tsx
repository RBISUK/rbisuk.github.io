'use client';
import { useEffect, useRef } from 'react';

export default function FloatBubbles({ className = '' }: { className?: string }) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const root = ref.current!;
    const n = Math.min(8, Math.max(4, Math.floor(window.innerWidth / 300)));
    for (let i = 0; i < n; i++) {
      const b = document.createElement('span');
      b.className = 'bubble';
      b.style.left = `${Math.random() * 100}%`;
      b.style.animationDelay = `${Math.random() * 4}s`;
      b.style.animationDuration = `${10 + Math.random() * 10}s`;
      root.appendChild(b);
    }
    return () => { root.innerHTML = ''; };
  }, []);

  return <div ref={ref} aria-hidden className={`bubbles ${className}`} />;
}