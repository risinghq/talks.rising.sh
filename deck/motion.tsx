"use client";

import { motion, type Variants } from "motion/react";
import type { CSSProperties, ReactNode } from "react";

export const EASE = [0.22, 1, 0.36, 1] as const;

const reveal: Variants = {
  hidden: { opacity: 0, y: 22, filter: "blur(8px)" },
  show: (i: number = 0) => ({
    opacity: 1,
    y: 0,
    filter: "blur(0px)",
    transition: { duration: 0.7, ease: EASE, delay: 0.08 + i * 0.07 },
  }),
};

export function R({ i = 0, children, className, style, as = "div" }: { i?: number; children: ReactNode; className?: string; style?: CSSProperties; as?: "div" | "span" | "p" | "h1" | "h2" }) {
  const C = motion[as];
  return (
    <C className={className} style={style} variants={reveal} custom={i} initial="hidden" animate="show">
      {children}
    </C>
  );
}
