#import "config.typ": colors, fonts, sizes

#let theme(
  aspect-ratio: "16-9",
  body,
) = {
  set page(
    paper: "presentation-" + aspect-ratio,
    fill: colors.bg,
    margin: (x: 3em, y: 2em),
  )

  set text(
    font: fonts.sans,
    size: sizes.body,
    fill: colors.fg,
    weight: 400,
  )

  // Heading styles
  show heading.where(level: 1): set text(
    size: sizes.h1,
    weight: 600,
    fill: colors.fg,
  )

  show heading.where(level: 2): set text(
    size: sizes.h2,
    weight: 600,
    fill: colors.fg,
  )

  show heading.where(level: 3): set text(
    size: sizes.h3,
    weight: 500,
    fill: colors.fg,
  )

  // Link styling
  show link: set text(fill: colors.accent)

  // Code block styling
  show raw.where(block: true): it => {
    block(
      width: 100%,
      fill: colors.accent-bg,
      stroke: none,
      radius: 4pt,
      inset: 1.2em,
      {
        set text(
          font: fonts.mono,
          size: sizes.tiny,
          fill: colors.fg,
        )
        it
      },
    )
  }

  // Inline code styling
  show raw.where(block: false): it => {
    box(
      fill: colors.accent-bg,
      outset: (x: 4pt, y: 2pt),
      radius: 3pt,
      text(
        font: fonts.mono,
        size: 0.9em,
        fill: colors.fg,
        it,
      ),
    )
  }

  // List styling
  set list(
    indent: 1em,
    body-indent: 0.5em,
    marker: ([•], [◦], [▸]),
  )

  set enum(
    indent: 1em,
    body-indent: 0.5em,
  )

  // Paragraph styling
  set par(
    leading: 0.7em,
    justify: false,
  )

  // Strong and emphasis
  show strong: set text(weight: 600)
  show emph: set text(style: "italic", fill: colors.muted)

  body
}
