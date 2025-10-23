#import "../config.typ": colors, spacing

#let divider(space: spacing.lg) = {
  v(space)
  line(length: 100%, stroke: 0.75pt + colors.border)
  v(space)
}
