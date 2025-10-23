#import "../config.typ": colors, radius

#let progress(value, total: 100, color: colors.accent) = {
  let percentage = calc.min(100, (value / total) * 100)
  stack(
    dir: ltr,
    block(
      width: 100%,
      height: 6pt,
      fill: colors.gray-200,
      radius: radius.full,
      box(
        width: percentage * 1%,
        height: 100%,
        fill: color,
        radius: radius.full,
      ),
    ),
  )
}
