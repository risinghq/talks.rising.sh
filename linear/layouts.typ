#import "config.typ": colors

// Two-column layout helper
#let two-columns(left, right, split: 50%) = {
  grid(
    columns: (split, 1fr),
    column-gutter: 2em,
    left, right,
  )
}

// Three-column layout helper
#let three-columns(left, center, right) = {
  grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 1.5em,
    left, center, right,
  )
}

// Grid layout helper for cards or other components
// Note: Grid rows automatically have equal heights in Typst
#let grid-layout(
  columns: 2,
  gutter: 1em,
  ..children,
) = {
  grid(
    columns: (1fr,) * columns,
    column-gutter: gutter,
    row-gutter: gutter,
    ..children.pos(),
  )
}
