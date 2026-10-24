"use client";

import type { ReactNode } from "react";
import { R } from "./motion";

export type Slide = { id: string; dark?: boolean; className?: string; notes: string; speaker?: string; render: (n: string) => ReactNode };

export function Eyebrow({ children }: { children: ReactNode }) {
  return (
    <R className="eyebrow">
      <i />
      {children}
    </R>
  );
}

export function Foot({ left, right }: { left: ReactNode; right?: ReactNode }) {
  return (
    <R className="foot" i={6}>
      <span>{left}</span>
      <span>{right}</span>
    </R>
  );
}
