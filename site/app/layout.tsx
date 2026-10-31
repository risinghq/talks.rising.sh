import type { Metadata } from "next";
import "@slides/deck/styles.css";
import "./index.css";

export const metadata: Metadata = {
  title: "Presentaciones · Rising",
  description: "Charlas y talleres de Rising, como presentaciones web.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  );
}
