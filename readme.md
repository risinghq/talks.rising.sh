# Slides

David's talks, served at
[slides.empirical.workers.dev](https://slides.empirical.workers.dev). Web talks
are React decks in one Next.js site. Typst talks compile to a PDF that the site
serves.

| Talk | Source | Watch |
| --- | --- | --- |
| Diversidad Vegetal | [`talks/diversidad-vegetal/`](talks/diversidad-vegetal) | [Web](https://slides.empirical.workers.dev/diversidad-vegetal/) |
| Deploy en la nube: Django on AWS | [`talks/deploy-django/`](talks/deploy-django) | [PDF](https://slides.empirical.workers.dev/deploy-django.pdf) |

[mise](https://mise.jdx.dev) installs the tools and runs every task:

```sh
mise run dev      # the site at http://localhost:3000
mise run check    # typecheck, dead code and formatting
mise run build    # the talk PDFs and the static site, into site/out
mise run deploy   # build, then upload to the Cloudflare Worker
mise tasks --all  # every task, including each talk's own
```

In a web deck, the arrow keys or a click on either side of the slide move
between slides. `N` shows the notes, `F` goes full screen, and `#2` in the URL
opens the second slide. The `PDF` button prints one slide per page.

A web talk is a Bun workspace in `talks/` that builds on the engine in
[`packages/deck/`](packages/deck) and gets a route in [`site/app/`](site/app).
A Typst talk imports the theme in [`packages/linear/`](packages/linear) and
gets a `pdfs` step in [`mise.toml`](mise.toml). Either kind gets a card in
[`site/app/page.tsx`](site/app/page.tsx).

The deck engine comes from [Railly/talks](https://github.com/Railly/talks), MIT
licensed; its license is in [`packages/deck/LICENSE`](packages/deck/LICENSE).
