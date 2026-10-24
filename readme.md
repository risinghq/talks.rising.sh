# Slides

David's talks. The web decks are one Next.js site at
[slides.empirical.workers.dev](https://slides.empirical.workers.dev). The Typst
talk in [`typst/`](typst) compiles to a PDF.

| Talk | Where |
| --- | --- |
| Diversidad Vegetal: comparison tables of fungi and lichens, bryophytes and ferns | [`/diversidad-vegetal/`](https://slides.empirical.workers.dev/diversidad-vegetal/) |
| Deploying Django to AWS with Docker, Terraform and nginx | [`typst/`](typst) |

```sh
bun install
bun run dev     # http://localhost:3000
```

In a deck, use the arrow keys or click a side of the slide to move between
slides. Press `N` for the notes and `F` for full screen. `#2` in the URL opens
the second slide. The `PDF` button prints the deck with one slide per page;
choose "Save as PDF" in the print dialog.

## Layout

| Path | Holds |
| --- | --- |
| [`deck/`](deck) | The slide engine every web deck uses. |
| [`talks/`](talks) | One folder per web talk: its slides, data and styles. |
| [`app/`](app) | The routes. Each talk gets a folder named for its URL. |
| [`public/`](public) | Fonts, and one folder of images per talk. |
| [`worker/`](worker) | The Cloudflare Worker that serves the built site. |
| [`typst/`](typst) | The Typst talk, its `linear` theme and the Django example. |

## Diversidad Vegetal

Each topic is a plain data file in
[`talks/diversidad-vegetal/topics/`](talks/diversidad-vegetal/topics). A row
holds one cell per column, written as `[text, span]`. A span wider than 1
merges columns that share the trait, and `**word**` marks a key term. A table
with a `tone` uses that palette for its slide. The palettes live in
[`theme.css`](talks/diversidad-vegetal/theme.css).

[`table.tsx`](talks/diversidad-vegetal/table.tsx) turns a topic into slides,
and [`topics/index.ts`](talks/diversidad-vegetal/topics/index.ts) lists the
topics the site builds.

## Checks

```sh
bun run typecheck
bun run lint:dead   # fallow: unused files, exports and dependencies
```

CI runs both and a build on every push and pull request.

## Deploy

```sh
bun run deploy
```

It builds the static site into `out/`, then the Worker in `worker/` uploads
`out/` as static assets with the `cf` CLI.

## Typst

```sh
cd typst
mise run compile    # main.pdf
```

[`typst/mise.toml`](typst/mise.toml) pins Typst and lists the other tasks.

## Credit

The deck engine in [`deck/`](deck) comes from
[Railly/talks](https://github.com/Railly/talks), MIT licensed. Its license is in
[`deck/LICENSE`](deck/LICENSE).
