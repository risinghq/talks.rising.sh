import type { Metadata } from "next";
import "@slides/deck/styles.css";
import "./index.css";

export const metadata: Metadata = {
  title: "Slides",
  description: "Presentaciones de David.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  );
}
