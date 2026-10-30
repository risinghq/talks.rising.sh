"use client";

import type { MDXContent } from "mdx/types";
import { Children, cloneElement, isValidElement, type ReactElement, type ReactNode } from "react";
import { R } from "./motion";
import { Eyebrow, Foot, type Slide } from "./ui";

type Outline = { title: ReactNode; slide: number }[];
// The deck passes `n` and `outline` to every slide element; an MDX file never sets them.
type Injected = { n?: string; outline?: Outline };
type SlideProps = Injected & { notes?: string; children?: ReactNode };

export function Title({ title, subtitle, children }: SlideProps & { title: ReactNode; subtitle?: ReactNode }) {
  return (
    <div className="m-title">
      <R as="h1">{title}</R>
      {subtitle && <R i={1} as="p" className="m-lead">{subtitle}</R>}
      {children && <R i={2} className="m-meta">{children}</R>}
    </div>
  );
}

export function Agenda({ title, outline = [] }: SlideProps & { title: ReactNode }) {
  return (
    <>
      <Eyebrow>Agenda</Eyebrow>
      <R i={1} as="h2" className="m-head">{title}</R>
      <R i={2} as="div" className="m-agenda">
        <ol>
          {outline.map((s) => (
            <li key={s.slide}>
              <a href={`#${s.slide}`}>{s.title}</a>
            </li>
          ))}
        </ol>
      </R>
    </>
  );
}

export function Section({ children }: SlideProps) {
  return (
    <div className="m-section">
      <R className="m-rule" />
      <R i={1} as="h1">{children}</R>
    </div>
  );
}

export function Focus({ children }: SlideProps) {
  return (
    <R i={1} className="m-focus">
      <p>{children}</p>
    </R>
  );
}

export function Content({ title, subtitle, children, n }: SlideProps & { title: ReactNode; subtitle?: ReactNode }) {
  return (
    <>
      <Eyebrow>{title}</Eyebrow>
      {subtitle && <R i={1} as="h2" className="m-head">{subtitle}</R>}
      <R i={2} className="m-body">{children}</R>
      <Foot left={title} right={n} />
    </>
  );
}

export function Picture({ src, alt = "" }: SlideProps & { src: { src: string }; alt?: string }) {
  return (
    <R className="m-picture">
      <img src={src.src} alt={alt} />
    </R>
  );
}

export function Callout({ title, children }: { title?: ReactNode; children: ReactNode }) {
  return (
    <aside className="m-callout">
      {title && <b>{title}</b>}
      {children}
    </aside>
  );
}

// Markdown inside a JSX element becomes several sibling blocks, so each column
// is its own element. `split` gives the column widths as grid tracks, as in
// "2fr 3fr", for a column of code that needs more room than its neighbour.
export function Columns({ children, split }: { children: ReactNode; split?: string }) {
  return (
    <div className="m-columns" style={split ? { gridTemplateColumns: split } : undefined}>
      {children}
    </div>
  );
}

export function Col({ children }: { children: ReactNode }) {
  return <div className="m-col">{children}</div>;
}

// `width` is a share of the slide body, as in "60%".
export function Figure({ src, alt = "", width }: { src: { src: string }; alt?: string; width?: string }) {
  return (
    <figure className="m-figure">
      <img src={src.src} alt={alt} style={{ width }} />
    </figure>
  );
}

const darkSlides = new Set<unknown>([Focus]);

// An MDX file compiles to one fragment of its top-level elements, and its
// content uses no hooks, so calling it outside render yields those elements:
// each one is a slide.
export function mdxSlides(content: MDXContent): Slide[] {
  const root = content({}) as ReactElement<{ children?: ReactNode }>;
  const elements = Children.toArray(root.props.children).filter(isValidElement<SlideProps>);
  const outline: Outline = elements.flatMap((el, k) => (el.type === Section ? [{ title: el.props.children, slide: k + 1 }] : []));
  return elements.map((el, k) => ({
    id: String(k),
    dark: darkSlides.has(el.type),
    notes: el.props.notes ?? "",
    render: (n: string) => cloneElement(el, { n, outline } satisfies Injected),
  }));
}
