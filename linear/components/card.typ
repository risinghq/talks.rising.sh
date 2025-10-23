#import "../config.typ": colors, radius, sizes

#let card(title: none, body, footer: none, highlight: false) = {
  block(
    width: 100%,
    fill: if highlight { colors.gray-50 } else { colors.bg },
    stroke: 0.75pt + colors.border,
    radius: radius.md,
    inset: (x: 1.5em, y: 1.3em),
    breakable: false,
    {
      if title != none {
        text(size: sizes.h2, weight: 600, fill: colors.fg, title)
        v(0.4em)
      }
      set text(size: sizes.small, fill: colors.gray-600, weight: 400)
      set par(leading: 0.65em)
      body
      if footer != none {
        v(0.7em)
        line(length: 100%, stroke: 0.75pt + colors.gray-200)
        v(0.5em)
        text(size: sizes.small, fill: colors.gray-400, weight: 400, footer)
      }
    },
  )
}
