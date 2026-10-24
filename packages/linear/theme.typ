#import "config.typ": colors, fonts, radius, sizes, spacing

#let theme(
  aspect-ratio: "16-9",
  body,
) = {
  set page(
    paper: "presentation-" + aspect-ratio,
    fill: colors.bg,
    margin: (x: 4em, y: 3em),
  )

  set text(
    font: fonts.sans,
    size: sizes.body,
    fill: colors.fg,
    weight: 400,
    fallback: true,
  )

  show heading.where(level: 1): it => {
    set text(size: sizes.h1, weight: 600, fill: colors.fg)
    block(above: 1.2em, below: 0.8em, it)
  }

  show heading.where(level: 2): it => {
    set text(size: sizes.h2, weight: 600, fill: colors.fg)
    block(above: 1em, below: 0.6em, it)
  }

  show heading.where(level: 3): it => {
    set text(size: sizes.h3, weight: 600, fill: colors.fg)
    block(above: 0.8em, below: 0.5em, it)
  }

  show link: it => text(fill: colors.accent, weight: 500, it)

  show raw.where(block: true): it => {
    set par(leading: 0.65em)
    block(
      width: 100%,
      fill: colors.code-bg,
      stroke: 0.75pt + colors.code-border,
      radius: radius.md,
      inset: (x: 1.5em, y: 1.2em),
      breakable: false,
      {
        set text(
          font: fonts.mono,
          size: 1em,
          fill: colors.code-text,
          weight: 400,
        )
        it
      },
    )
  }

  show raw.where(block: false): it => {
    box(
      fill: colors.gray-100,
      outset: (x: 0.3em, y: 0.15em),
      radius: radius.sm,
      baseline: 10%,
      text(
        font: fonts.mono,
        size: 1em,
        fill: colors.gray-700,
        weight: 500,
        it,
      ),
    )
  }

  set list(
    indent: 0em,
    body-indent: 1em,
    marker: ([•], [◦], [▸]),
    spacing: 0.85em,
  )
  show list.item: it => {
    set text(/*fill: colors.gray-700,*/ size: sizes.body)
    it
  }

  set enum(indent: 0em, body-indent: 1em, spacing: 1.25em)
  show enum.item: it => {
    set text(/*fill: colors.gray-700,*/ size: sizes.body)
    it
  }

  set par(leading: 0.8em, justify: false, spacing: 1.2em)

  show grid: it => {
    set par(spacing: 0.6em)
    it
  }

  show strong: set text(weight: 600, fill: colors.fg)
  show emph: set text(style: "italic", fill: colors.gray-600)

  show table: it => {
    set text(size: sizes.body)
    block(width: 100%, stroke: none, it)
  }

  show table.cell: it => {
    set align(left)
    set text(fill: colors.fg)
    it
  }

  set line(stroke: 1pt + colors.gray-200)

  show terms: set text(size: sizes.body)
  show terms.item: it => {
    text(weight: 600, fill: colors.fg, it.term)
    [ — ]
    text(fill: colors.gray-600, it.description)
  }

  body
}
