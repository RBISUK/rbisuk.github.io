import './globals.css';
import type { ReactNode } from 'react';

export const metadata = {
  title: 'RBIS UK',
  description: 'Professional information hub for RBIS UK',
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen flex flex-col items-center justify-start">
        {children}
      </body>
    </html>
  );
}
