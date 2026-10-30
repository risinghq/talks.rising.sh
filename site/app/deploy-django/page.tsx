import type { Metadata } from "next";
import { TalkDeck } from "@slides/deploy-django";
import "@slides/deck/mdx.css";
import "@slides/deploy-django/theme.css";

export const metadata: Metadata = {
  title: "Deploy en la nube",
  description: "Django en AWS con Docker, Terraform y nginx.",
};

export default function Page() {
  return <TalkDeck />;
}
