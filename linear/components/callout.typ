#import "../config.typ": colors, radius, sizes

#let callout(body, title: none, type: "default") = {
  let (bg-color, border-color) = if type == "success" {
    (colors.gray-50, colors.gray-400)
  } else if type == "warning" {
    (colors.gray-50, colors.gray-400)
  } else if type == "danger" {
    (colors.gray-50, colors.gray-400)
  } else if type == "info" {
    (colors.gray-50, colors.gray-400)
  } else {
    (colors.gray-50, colors.gray-400)
  }

  block(
    width: 100%,
    fill: bg-color,
    stroke: (
      left: 4pt + border-color,
      rest: 0.5pt + colors.gray-200,
    ),
    radius: radius.md,
    inset: (x: 1.2em, y: 1em),
    breakable: false,
    {
      if title != none {
        text(weight: 700, size: sizes.body, fill: colors.gray-900)[#title]
      }
      set text(size: sizes.body, fill: colors.gray-700, weight: 400)
      set par(leading: 0.7em)
      body
    },
  )
}
