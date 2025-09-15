"use client";
import { motion } from "framer-motion";
import Link from "next/link";
export default function SupportBubble() {
  return (
    <div className="fixed bottom-5 right-5 z-50">
      <motion.div initial={{scale:0.9,opacity:0}} animate={{scale:1,opacity:1}} transition={{type:"spring",stiffness:200,damping:15}}>
        <Link href="/hdr/form" aria-label="Rapid Support"
          className="btn btn-primary rounded-full h-14 w-14 p-0 text-base">
          💬
        </Link>
      </motion.div>
    </div>
  );
}
