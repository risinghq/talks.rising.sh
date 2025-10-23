#import "../config.typ": colors, sizes

#let metric(value, label, change: none) = {
  block(
    width: 100%,
    {
      text(size: sizes.h1, weight: 600, fill: colors.fg)[#value]
      v(0.25em)
      text(size: sizes.small, fill: colors.muted)[#label]
      if change != none {
        v(0.25em)
        let change-color = if type(change) == str and change.starts-with("+") {
          colors.success
        } else if type(change) == str and change.starts-with("-") {
          colors.danger
        } else {
          colors.muted
        }
        text(size: sizes.small, fill: change-color, weight: 500)[#change]
      }
    },
  )
}
