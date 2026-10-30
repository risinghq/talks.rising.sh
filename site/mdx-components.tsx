import type { MDXComponents } from "mdx/types";

// The App Router needs this file to render MDX. Talks import their slide
// components; this sets only what every talk shares. A link opens a new tab so
// the deck keeps its place.
export function useMDXComponents(components: MDXComponents): MDXComponents {
  return {
    a: (props) => <a {...props} target="_blank" rel="noreferrer" />,
    ...components,
  };
}
