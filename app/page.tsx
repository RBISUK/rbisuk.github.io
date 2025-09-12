'use client';

import { motion } from 'framer-motion';
import SpinningCube from '../components/SpinningCube';

export default function Home() {
  return (
    <main className="flex flex-col items-center justify-center p-24 space-y-10">
      <motion.h1
        className="text-5xl font-bold"
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        RBIS UK
      </motion.h1>
      <p className="mt-6 text-xl text-center max-w-2xl">
        Elite information hub showcasing services, software solutions, and industry insights.
      </p>
      <SpinningCube />
    </main>
  );
}
