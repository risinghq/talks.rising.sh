"use client";

import { Deck } from "@slides/deck";
import { mdxSlides } from "@slides/deck/mdx";
import Talk from "./slides.mdx";

const slides = mdxSlides(Talk);

export function TalkDeck() {
  return (
    <div className="theme-deploy-django">
      <Deck slides={slides} />
    </div>
  );
}
