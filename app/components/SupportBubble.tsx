"use client";
import {motion} from "framer-motion";
import Link from "next/link";
export default function SupportBubble(){
  return (
    <motion.div
      initial={{scale:0.9, opacity:0}}
      animate={{scale:1, opacity:1}}
      transition={{type:"spring", stiffness:200, damping:15, delay:0.2}}
      className="fixed bottom-5 right-5 z-40"
    >
      <Link href="/main/contact" className="btn shadow-lg">
        Rapid Support
      </Link>
    </motion.div>
  );
}
