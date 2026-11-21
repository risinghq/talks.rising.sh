import type { Metadata } from "next";
import "@slides/deck/styles.css";
import "./index.css";

// app/opengraph-image.png, icon.svg and apple-icon.png become head tags; the
// base makes the image URL absolute, as social crawlers require.
export const metadata: Metadata = {
  metadataBase: new URL("https://talks.rising.sh"),
  title: "Presentaciones · rising.sh",
  description: "Charlas y talleres de rising.sh, como presentaciones web.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  );
}
