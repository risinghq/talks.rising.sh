#import "../config.typ": colors, radius

#let highlight(body) = {
  box(
    fill: colors.warning-bg,
    inset: (x: 0.4em, y: 0.2em),
    radius: radius.sm,
    baseline: 15%,
    text(fill: colors.warning.darken(20%), weight: 500, body),
  )
}
