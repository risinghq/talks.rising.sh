# talks.rising.sh

Talks and workshops as web slide decks, served at
[talks.rising.sh](https://talks.rising.sh). Each talk is a deck in one Next.js
site.

| Talk | Source | Watch |
| --- | --- | --- |
| Diversidad Vegetal | [`talks/diversidad-vegetal/`](talks/diversidad-vegetal) | [Web](https://talks.rising.sh/diversidad-vegetal/) |
| Deploy en la nube: Django on AWS | [`talks/deploy-django/`](talks/deploy-django) | [Web](https://talks.rising.sh/deploy-django/) |

[mise](https://mise.jdx.dev) installs the tools and runs every task:

```sh
mise run dev      # the site at http://localhost:3000
mise run check    # typecheck, dead code and formatting
mise run build    # the static site, into site/out
mise run deploy   # build, then upload to the Cloudflare Worker
mise tasks --all  # every task, including each talk's own
```

A push to `master` deploys the site through
[`.github/workflows/deploy.yml`](.github/workflows/deploy.yml), with the repo
secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`. `mise run deploy`
by hand uses the `cf` profile bound to the checkout
(`cf auth activate <profile> .`).

In a deck, the arrow keys or a click on either side of the slide move between
slides. `N` shows the notes, `F` goes full screen, and `#2` in the URL opens the
second slide. The `PDF` button prints one slide per page.

A talk is a Bun workspace in `talks/` that builds on the engine in
[`packages/deck/`](packages/deck). It gets a route in [`site/app/`](site/app)
and a card in [`site/app/page.tsx`](site/app/page.tsx).

A talk made of prose and code is written in MDX, as
[`talks/deploy-django/`](talks/deploy-django) is. Its `slides.mdx` lists one
slide per top-level element, using the components in
[`packages/deck/mdx.tsx`](packages/deck/mdx.tsx): `Title`, `Agenda`, `Section`,
`Focus`, `Content`, `Picture`, `Columns` with `Col`, `Callout` and `Figure`.
`mdxSlides` turns the file into a deck. Code blocks are highlighted at build
time.

The deck engine comes from [Railly/talks](https://github.com/Railly/talks), MIT
licensed; its license is in [`packages/deck/LICENSE`](packages/deck/LICENSE).
