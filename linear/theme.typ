#import "config.typ": colors, fonts, sizes, spacing, radius

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

  // Heading styles - Linear's clean hierarchy
  show heading.where(level: 1): it => {
    set text(
      size: sizes.h1,
      weight: 600,
      fill: colors.fg,
    )
    block(
      above: 1.5em,
      below: 1em,
      it
    )
  }

  show heading.where(level: 2): it => {
    set text(
      size: sizes.h2,
      weight: 600,
      fill: colors.fg,
    )
    block(
      above: 1.2em,
      below: 0.8em,
      it
    )
  }

  show heading.where(level: 3): it => {
    set text(
      size: sizes.h3,
      weight: 600,
      fill: colors.fg,
    )
    block(
      above: 1em,
      below: 0.6em,
      it
    )
  }

  show heading.where(level: 4): it => {
    set text(
      size: sizes.h4,
      weight: 600,
      fill: colors.fg,
    )
    block(
      above: 0.8em,
      below: 0.5em,
      it
    )
  }

  // Link styling - Linear's accent color
  show link: it => {
    text(fill: colors.accent, weight: 500, it)
  }

  // Code block styling - dark theme inspired by Linear
  show raw.where(block: true): it => {
    set par(leading: 0.65em)
    block(
      width: 100%,
      fill: colors.nordic-gray,
      stroke: none,
      radius: radius.md,
      inset: (x: 1.5em, y: 1.2em),
      breakable: false,
      {
        set text(
          font: fonts.mono,
          size: 0.8em,
          fill: colors.mercury-white,
          weight: 400,
        )
        it
      },
    )
  }

  // Inline code styling
  show raw.where(block: false): it => {
    box(
      fill: colors.gray-100,
      outset: (x: 0.3em, y: 0.15em),
      radius: radius.sm,
      baseline: 10%,
      text(
        font: fonts.mono,
        size: 0.85em,
        fill: colors.gray-700,
        weight: 500,
        it,
      ),
    )
  }

  // List styling - clean and minimal
  set list(
    indent: 0em,
    body-indent: 1em,
    marker: ([•], [◦], [▸]),
    spacing: 0.5em,
  )

  show list.item: it => {
    set text(fill: colors.gray-700, size: sizes.small)
    it
  }

  set enum(
    indent: 0em,
    body-indent: 1em,
    spacing: 0.5em,
  )

  show enum.item: it => {
    set text(fill: colors.gray-700, size: sizes.small)
    it
  }

  // Paragraph styling - optimized for readability
  set par(
    leading: 0.8em,
    justify: false,
    spacing: 0.8em,
  )

  // Strong and emphasis
  show strong: set text(weight: 600, fill: colors.fg)
  show emph: set text(style: "italic", fill: colors.gray-600)

  // Table styling
  show table: it => {
    set text(size: sizes.small)
    block(
      width: 100%,
      stroke: none,
      radius: radius.md,
      it
    )
  }

  show table.cell: it => {
    set align(left)
    set text(fill: colors.fg)
    it
  }

  // Horizontal rule
  set line(stroke: 1pt + colors.gray-200)

  // Terms (definition lists)
  show terms: set text(size: sizes.small)
  show terms.item: it => {
    text(weight: 600, fill: colors.fg, it.term)
    [ — ]
    text(fill: colors.gray-600, it.description)
  }

  body
}
