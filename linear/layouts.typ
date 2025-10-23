#import "config.typ": spacing

#let two-columns(left, right, split: 50%) = {
  grid(
    columns: (split, 1fr),
    column-gutter: 2em,
    left, right,
  )
}

#let three-columns(left, center, right) = {
  grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 1.5em,
    left, center, right,
  )
}

#let grid-layout(columns: 2, gutter: 1em, ..children) = {
  grid(
    columns: (1fr,) * columns,
    rows: (auto,),
    column-gutter: gutter,
    row-gutter: gutter,
    ..children.pos(),
  )
}
