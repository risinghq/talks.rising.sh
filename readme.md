# Slides

David's talks. The web talks build into one Next.js site at
[slides.empirical.workers.dev](https://slides.empirical.workers.dev). The Typst
talks compile to PDF.

| Talk | Kind | Where |
| --- | --- | --- |
| Diversidad Vegetal: comparison tables of fungi and lichens, bryophytes and ferns | Web | [`/diversidad-vegetal/`](https://slides.empirical.workers.dev/diversidad-vegetal/) |
| Deploying Django to AWS with Docker, Terraform and nginx | Typst | [`talks/deploy-django/`](talks/deploy-django) |

```sh
bun install
bun run dev     # http://localhost:3000
```

In a web deck, use the arrow keys or click a side of the slide to move between
slides. Press `N` for the notes and `F` for full screen. `#2` in the URL opens
the second slide. The `PDF` button prints the deck with one slide per page;
choose "Save as PDF" in the print dialog.

## Layout

| Path | Holds |
| --- | --- |
| [`packages/deck/`](packages/deck) | `@slides/deck`: the engine and fonts every web talk uses. |
| [`packages/linear/`](packages/linear) | The Typst theme every Typst talk uses, and its font script. |
| [`talks/`](talks) | One folder per talk, with its slides, data and images. A web talk is a workspace package. |
| [`site/`](site) | The Next.js app. Each web talk gets a route folder named for its URL. |
| [`worker/`](worker) | The Cloudflare Worker that serves the built site. |

The root [`package.json`](package.json) lists the workspaces, and one
`bun.lock` pins every package. [`mise.toml`](mise.toml) pins Bun, Typst and uv.

## Add a web talk

1. Make a package in `talks/<name>/` that depends on `@slides/deck` and
   exports its slides.
2. Add it to `workspaces` in the root `package.json`, to the site's
   dependencies, and to `transpilePackages` in
   [`site/next.config.ts`](site/next.config.ts).
3. Add a route folder `site/app/<name>/` and a card in
   [`site/app/page.tsx`](site/app/page.tsx).

## Diversidad Vegetal

Each topic is a plain data file in
[`talks/diversidad-vegetal/topics/`](talks/diversidad-vegetal/topics). A row
holds one cell per column, written as `[text, span]`. A span wider than 1
merges columns that share the trait, and `**word**` marks a key term. A table
with a `tone` uses that palette for its slide. The palettes live in
[`theme.css`](talks/diversidad-vegetal/theme.css), and the photos in
[`img/`](talks/diversidad-vegetal/img).

[`table.tsx`](talks/diversidad-vegetal/table.tsx) turns a topic into slides,
and [`topics/index.ts`](talks/diversidad-vegetal/topics/index.ts) lists the
topics the site builds.

## Typst

```sh
mise --cd packages/linear run fonts          # once: Geist for the theme
mise --cd talks/deploy-django run compile    # talks/deploy-django/main.pdf
```

Each folder's `mise.toml` lists its other tasks.

## Checks

```sh
bun run typecheck
bun run lint:dead   # fallow: unused files, exports and dependencies
```

CI runs both and a site build on every push and pull request. It also checks
the Typst formatting and compiles the Typst talk.

## Deploy

```sh
bun run deploy
```

It builds the static site into `site/out/`, then the Worker in `worker/`
uploads it as static assets with the `cf` CLI.

## Credit

The deck engine in [`packages/deck/`](packages/deck) comes from
[Railly/talks](https://github.com/Railly/talks), MIT licensed. Its license is in
[`packages/deck/LICENSE`](packages/deck/LICENSE).
