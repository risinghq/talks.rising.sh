#import "../config.typ": colors, radius, sizes

#let button(body, type: "primary") = {
  let (bg-color, text-color, border-color) = if type == "primary" {
    (colors.accent, colors.bg, colors.accent)
  } else if type == "secondary" {
    (colors.bg, colors.fg, colors.border)
  } else if type == "danger" {
    (colors.danger, colors.bg, colors.danger)
  } else {
    (colors.gray-50, colors.fg, colors.gray-200)
  }

  box(
    fill: bg-color,
    stroke: 0.75pt + border-color,
    inset: (x: 1em, y: 0.5em),
    radius: radius.sm,
    baseline: 15%,
    text(size: sizes.small, weight: 500, fill: text-color, body),
  )
}
