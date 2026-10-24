"use client";

import { Deck } from "@slides/deck";
import { topicBySlug } from "./topics";
import { topicSlides } from "./table";

// Slides hold render functions, which cannot cross from a server page, so the
// client looks the topic up by slug.
export function TopicDeck({ slug }: { slug: string }) {
  const topic = topicBySlug(slug);
  if (!topic) return null;
  return (
    <div className={`theme-${slug}`}>
      <Deck slides={topicSlides(topic)} />
    </div>
  );
}
