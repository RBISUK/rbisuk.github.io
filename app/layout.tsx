import './globals.css';
import type { ReactNode } from 'react';
import NavBar from '../components/NavBar';
import Footer from '../components/Footer';
import Disclaimer from '../components/Disclaimer';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'RBIS Demo',
  description: 'Demo version – not indexed',
  robots: {
    index: false,
    follow: false,
  },
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen flex flex-col" id="top">
        <NavBar />
        <main className="flex-grow w-full">{children}</main>
        <Disclaimer />
        <Footer />
      </body>
    </html>
  );
}
