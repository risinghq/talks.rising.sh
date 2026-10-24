import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { TopicDeck, topicBySlug, topics } from "@slides/diversidad-vegetal";

type Props = { params: Promise<{ tema: string }> };

export const dynamicParams = false;

export function generateStaticParams() {
  return topics.map((t) => ({ tema: t.slug }));
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const topic = topicBySlug((await params).tema);
  return { title: `Cuadro comparativo de ${topic?.name.toLowerCase()}`, description: topic?.summary };
}

export default async function Page({ params }: Props) {
  const { tema } = await params;
  if (!topicBySlug(tema)) notFound();
  return <TopicDeck slug={tema} />;
}
