'use client';
import Link from 'next/link';
import { useState } from 'react';
import { motion } from 'framer-motion';

export default function NavBar() {
  const [open, setOpen] = useState(false);
  return (
    <nav className="w-full bg-gradient-to-r from-blue-500 to-teal-400 text-white shadow-md sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <Link href="#top" className="text-xl font-bold">RBIS UK</Link>
          <button className="sm:hidden" onClick={() => setOpen(!open)}>
            <span className="text-2xl">☰</span>
          </button>
          <div className="hidden sm:flex space-x-4">
            <Link href="#services" className="hover:underline">Services</Link>
            <Link href="#compliance" className="hover:underline">Compliance</Link>
            <Link href="#portal" className="hover:underline">Portal</Link>
            <Link href="#legal" className="hover:underline">Legal Hub</Link>
          </div>
        </div>
      </div>
      {open && (
        <motion.div
          initial={{ height: 0 }}
          animate={{ height: 'auto' }}
          className="sm:hidden px-4 pb-4 flex flex-col space-y-2 bg-blue-600"
        >
          <Link href="#services" onClick={() => setOpen(false)}>Services</Link>
          <Link href="#compliance" onClick={() => setOpen(false)}>Compliance</Link>
          <Link href="#portal" onClick={() => setOpen(false)}>Portal</Link>
          <Link href="#legal" onClick={() => setOpen(false)}>Legal Hub</Link>
        </motion.div>
      )}
    </nav>
  );
}
