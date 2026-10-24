# Diversidad Vegetal

Comparison tables for the UNMSM course, one deck per topic.

Each topic is a data file in [`topics/`](topics), listed in
[`topics/index.ts`](topics/index.ts). A row holds one cell per column, written
as `[text, span]`. A span wider than 1 merges columns that share the trait, and
`**word**` marks a key term. A table with a `tone` takes that palette from
[`theme.css`](theme.css). [`table.tsx`](table.tsx) turns a topic into slides.
