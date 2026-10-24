#import "../config.typ": colors, sizes

#let quote(body, author: none) = {
  block(
    width: 100%,
    inset: (left: 1em, y: 0.7em),
    stroke: (left: 2.5pt + colors.accent),
    {
      set text(size: sizes.body, fill: colors.fg, style: "italic", weight: 400)
      body
      if author != none {
        v(0.4em)
        text(
          size: sizes.small,
          fill: colors.muted,
          weight: 500,
          style: "normal",
        )[— #author]
      }
    },
  )
}
