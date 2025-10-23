#import "../config.typ": colors, radius

#let icon-box(icon, size: 40pt, bg: colors.gray-50) = {
  box(
    width: size * 1.4,
    height: size * 1.4,
    fill: bg,
    radius: radius.md,
    stroke: 0.75pt + colors.border,
    {
      set align(center + horizon)
      text(size: size, icon)
    },
  )
}
