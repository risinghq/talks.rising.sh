#import "../config.typ": colors, sizes

#let feature(body) = {
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.7em,
    align: (horizon, top),
    text(size: sizes.body, fill: colors.success, weight: 600)[✓],
    text(size: sizes.small, fill: colors.fg)[#body],
  )
}
