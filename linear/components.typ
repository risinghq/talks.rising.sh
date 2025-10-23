#import "config.typ": colors, fonts, sizes

// Callout box for highlighting information
#let callout(body, title: none) = {
  block(
    width: 100%,
    fill: colors.accent-bg,
    stroke: none,
    radius: 4pt,
    inset: 1.2em,
    {
      if title != none {
        text(weight: 600, size: sizes.small, fill: colors.fg)[#title]
        v(0.5em)
      }
      set text(size: sizes.small)
      body
    },
  )
}

// Card component for structured content
#let card(
  title: none,
  body,
  footer: none,
) = {
  block(
    width: 100%,
    fill: colors.bg,
    stroke: 0.5pt + colors.border,
    radius: 4pt,
    inset: 1.2em,
    {
      if title != none {
        text(size: sizes.body, weight: 600, fill: colors.fg, title)
        v(0.6em)
      }
      set text(size: sizes.small)
      body
      if footer != none {
        v(0.8em)
        block(
          width: 100%,
          stroke: (top: 0.5pt + colors.border),
          inset: (top: 0.8em),
          text(size: sizes.tiny, fill: colors.muted, footer),
        )
      }
    },
  )
}

// Badge for inline labels
#let badge(body) = {
  box(
    fill: colors.accent-bg,
    inset: (x: 8pt, y: 4pt),
    radius: 3pt,
    baseline: 20%,
    text(
      size: sizes.caption,
      weight: 500,
      fill: colors.fg,
      body,
    ),
  )
}
