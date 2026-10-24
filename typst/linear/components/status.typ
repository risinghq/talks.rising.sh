#import "../config.typ": colors, sizes

#let status(label, type: "default") = {
  let dot-color = if type == "success" {
    colors.success
  } else if type == "warning" {
    colors.warning
  } else if type == "danger" {
    colors.danger
  } else if type == "active" {
    colors.accent
  } else {
    colors.gray-400
  }

  box(
    grid(
      columns: (auto, 1fr),
      column-gutter: 0.5em,
      align: (horizon, horizon),
      circle(radius: 3pt, fill: dot-color),
      text(size: sizes.body, fill: colors.fg, label),
    ),
  )
}
