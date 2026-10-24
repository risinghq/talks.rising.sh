import type { Metadata } from "next";
import "@/talks/diversidad-vegetal/theme.css";

export const metadata: Metadata = {
  title: "Diversidad Vegetal · Cuadros comparativos",
  description: "Cuadros comparativos de hongos y líquenes, briofitos y helechos.",
};

export default function Layout({ children }: { children: React.ReactNode }) {
  return children;
}
