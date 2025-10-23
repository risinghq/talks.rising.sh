#import "../config.typ": colors, radius, sizes

#let badge(body, type: "default") = {
  let (bg-color, text-color) = if type == "accent" {
    (colors.accent, colors.bg)
  } else if type == "success" {
    (colors.success-bg, colors.success.darken(15%))
  } else if type == "warning" {
    (colors.warning-bg, colors.warning.darken(15%))
  } else if type == "danger" {
    (colors.danger-bg, colors.danger.darken(15%))
  } else if type == "info" {
    (colors.info-bg, colors.info.darken(15%))
  } else {
    (colors.gray-100, colors.gray-600)
  }

  box(
    fill: bg-color,
    inset: (x: 0.5em, y: 0.25em),
    radius: radius.sm,
    baseline: 13%,
    text(size: sizes.body, weight: 500, fill: text-color, body),
  )
}
