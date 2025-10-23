#let linear-colors = (
  bg: rgb("#ffffff"),
  fg: rgb("#18181b"),
  muted: rgb("#71717a"),
  border: rgb("#e4e4e7"),
  accent: rgb("#5e6ad2"),
  accent-bg: rgb("#f4f4f8"),
)

#let font-sans = "Geist"
#let font-mono = "Geist Mono"

#let linear-theme(
  aspect-ratio: "16-9",
  config-info: (:),
  body,
) = {
  set page(
    paper: "presentation-" + aspect-ratio,
    fill: linear-colors.bg,
    margin: (x: 3em, y: 2em),
  )

  set text(
    font: font-sans,
    size: 20pt,
    fill: linear-colors.fg,
    weight: 400,
  )

  show heading.where(level: 1): set text(
    size: 36pt,
    weight: 600,
    fill: linear-colors.fg,
  )

  show heading.where(level: 2): set text(
    size: 28pt,
    weight: 600,
    fill: linear-colors.fg,
  )

  show heading.where(level: 3): set text(
    size: 22pt,
    weight: 500,
    fill: linear-colors.fg,
  )

  // spacing after headings
  show heading: it => {
    it
    v(0.6em)
  }

  show link: set text(fill: linear-colors.accent)

  show raw.where(block: true): it => {
    block(
      width: 100%,
      fill: linear-colors.accent-bg,
      stroke: none,
      radius: 4pt,
      inset: 1.2em,
      {
        set text(
          font: font-mono,
          size: 16pt,
          fill: linear-colors.fg,
        )
        it
      },
    )
  }

  show raw.where(block: false): it => {
    box(
      fill: linear-colors.accent-bg,
      outset: (x: 4pt, y: 2pt),
      radius: 3pt,
      text(
        font: font-mono,
        size: 0.9em,
        fill: linear-colors.fg,
        it,
      ),
    )
  }

  set list(
    indent: 1em,
    body-indent: 0.5em,
    marker: ([•], [◦], [▸]),
  )

  set enum(
    indent: 1em,
    body-indent: 0.5em,
  )

  // Comfortable line spacing
  set par(
    leading: 0.7em,
    justify: false,
  )

  // Strong text
  show strong: set text(weight: 600)

  // Emphasis
  show emph: set text(style: "italic", fill: linear-colors.muted)

  body
}

// Standard slide template
#let slide(
  title: none,
  subtitle: none,
  footer: auto,
  body,
) = {
  let header-content = if title != none {
    block(
      width: 100%,
      inset: (bottom: 0.6em),
      {
        text(size: 28pt, weight: 600, fill: linear-colors.fg, title)
        if subtitle != none {
          v(0.3em)
          text(size: 18pt, weight: 400, fill: linear-colors.muted, subtitle)
        }
      },
    )
    v(1.2em)
  }

  let footer-content = if footer != auto and footer != none {
    v(1fr)
    block(
      width: 100%,
      inset: (top: 0.6em),
      stroke: (top: 0.5pt + linear-colors.border),
      {
        v(0.4em)
        set text(size: 14pt, fill: linear-colors.muted)
        footer
      },
    )
  }

  page({
    header-content
    body
    footer-content
  })
}

// Title slide
#let title-slide(
  title: none,
  subtitle: none,
  author: none,
  date: none,
) = {
  page({
    set align(center + horizon)

    block(
      width: 100%,
      {
        text(
          size: 48pt,
          weight: 600,
          fill: linear-colors.fg,
          title,
        )
      },
    )

    if subtitle != none {
      v(1em)
      block(
        width: 100%,
        {
          text(
            size: 24pt,
            weight: 400,
            fill: linear-colors.muted,
            subtitle,
          )
        },
      )
    }

    v(3em)

    if author != none or date != none {
      block(
        width: 100%,
        {
          set text(size: 18pt, fill: linear-colors.muted)
          if author != none { author }
          if author != none and date != none [ \ ]
          if date != none { date }
        },
      )
    }
  })
}

// Focus slide for key messages
#let focus-slide(body) = {
  page({
    set align(center + horizon)
    set text(size: 48pt, weight: 600, fill: linear-colors.fg)
    body
  })
}

// Two-column layout
#let two-columns(left, right, split: 50%) = {
  grid(
    columns: (split, 1fr),
    column-gutter: 2em,
    left, right,
  )
}

// Minimal callout - single style, no icons
#let callout(body, title: none) = {
  block(
    width: 100%,
    fill: linear-colors.accent-bg,
    stroke: none,
    radius: 4pt,
    inset: 1.2em,
    {
      if title != none {
        text(weight: 600, size: 18pt, fill: linear-colors.fg)[#title]
        v(0.5em)
      }
      set text(size: 18pt)
      body
    },
  )
}

// Simple card component
#let card(
  title: none,
  body,
  footer: none,
) = {
  block(
    width: 100%,
    fill: linear-colors.bg,
    stroke: 0.5pt + linear-colors.border,
    radius: 4pt,
    inset: 1.2em,
    {
      if title != none {
        text(size: 20pt, weight: 600, fill: linear-colors.fg, title)
        v(0.6em)
      }
      set text(size: 18pt)
      body
      if footer != none {
        v(0.8em)
        block(
          width: 100%,
          stroke: (top: 0.5pt + linear-colors.border),
          inset: (top: 0.8em),
          text(size: 16pt, fill: linear-colors.muted, footer),
        )
      }
    },
  )
}

// Minimal badge
#let badge(body) = {
  box(
    fill: linear-colors.accent-bg,
    inset: (x: 8pt, y: 4pt),
    radius: 3pt,
    baseline: 20%,
    text(
      size: 14pt,
      weight: 500,
      fill: linear-colors.fg,
      body,
    ),
  )
}

// Clean outline slide
#let outline-slide(title: [Contents], depth: 2) = {
  slide(title: title)[
    #set text(size: 20pt)

    #show outline.entry: it => {
      let indent = 1.5em * (it.level - 1)

      block(
        width: 100%,
        inset: (left: indent, y: 0.5em),
        {
          text(weight: if it.level == 1 { 600 } else { 400 }, it.body())
          h(1fr)
          text(fill: linear-colors.muted, it.page())
        },
      )
    }

    #outline(depth: depth)
  ]
}

#let linear = (
  theme: linear-theme,
  slide: slide,
  title-slide: title-slide,
  focus-slide: focus-slide,
  outline-slide: outline-slide,
  two-columns: two-columns,
  callout: callout,
  card: card,
  badge: badge,
  colors: linear-colors,
)
