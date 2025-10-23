#import "@preview/touying:0.6.1": *

// Color palette inspired by Linear/shadcn
#let linear-colors = (
  // Base colors
  bg: rgb("#fafafa"),
  fg: rgb("#09090b"),
  muted: rgb("#f4f4f5"),
  muted-fg: rgb("#71717a"),
  // Accent colors
  primary: rgb("#18181b"),
  primary-fg: rgb("#fafafa"),
  accent: rgb("#5e6ad2"),
  accent-light: rgb("#eef0fd"),
  // Border and dividers
  border: rgb("#e4e4e7"),
  border-strong: rgb("#d4d4d8"),
  // Semantic colors
  success: rgb("#22c55e"),
  warning: rgb("#f59e0b"),
  danger: rgb("#ef4444"),
  // Code blocks
  code-bg: rgb("#f9fafb"),
  code-border: rgb("#e5e7eb"),
)

// Typography scale
#let font-family = "Inter"
#let font-mono = ("JetBrains Mono", "Fira Code")

// Create the theme
#let linear-theme(
  aspect-ratio: "16-9",
  config-info: (:),
  body,
) = {
  set page(
    paper: "presentation-" + aspect-ratio,
    fill: linear-colors.bg,
    margin: (x: 2em, y: 1.5em),
  )

  set text(
    font: font-family,
    size: 20pt,
    fill: linear-colors.fg,
    weight: 400,
  )

  // Headings
  show heading.where(level: 1): set text(
    size: 48pt,
    weight: 600,
    fill: linear-colors.primary,
  )

  show heading.where(level: 2): set text(
    size: 32pt,
    weight: 600,
    fill: linear-colors.primary,
  )

  show heading.where(level: 3): set text(
    size: 24pt,
    weight: 500,
    fill: linear-colors.primary,
  )

  // Add subtle spacing after headings
  show heading: it => {
    it
    v(0.5em)
  }

  // Links
  show link: set text(fill: linear-colors.accent)
  show link: underline

  // Code blocks
  show raw.where(block: true): it => {
    block(
      width: 100%,
      fill: linear-colors.code-bg,
      stroke: (
        paint: linear-colors.code-border,
        thickness: 1pt,
      ),
      radius: 6pt,
      inset: 1em,
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

  // Inline code
  show raw.where(block: false): it => {
    box(
      fill: linear-colors.muted,
      outset: (x: 3pt, y: 2pt),
      radius: 3pt,
      text(
        font: font-mono,
        size: 0.9em,
        fill: linear-colors.fg,
        it,
      ),
    )
  }

  // Lists with custom styling
  set list(
    indent: 1em,
    body-indent: 0.5em,
    marker: ([•], [◦], [▸]),
  )

  set enum(
    indent: 1em,
    body-indent: 0.5em,
  )

  // Better line spacing
  set par(
    leading: 0.65em,
    justify: false,
  )

  // Strong text
  show strong: set text(weight: 600, fill: linear-colors.primary)

  // Emphasis
  show emph: set text(style: "italic", fill: linear-colors.muted-fg)

  body
}

// Slide template
#let slide(
  title: none,
  subtitle: none,
  footer: auto,
  show-header: true,
  body,
) = {
  let header-content = if show-header and title != none {
    block(
      width: 100%,
      inset: (bottom: 0.5em),
      stroke: (bottom: 1pt + linear-colors.border),
      {
        text(size: 28pt, weight: 600, fill: linear-colors.primary, title)
        if subtitle != none {
          v(0.3em)
          text(size: 18pt, fill: linear-colors.muted-fg, subtitle)
        }
      },
    )
    v(1em)
  }

  let footer-content = if footer != auto and footer != none {
    v(1fr)
    block(
      width: 100%,
      inset: (top: 0.5em),
      stroke: (top: 1pt + linear-colors.border),
      {
        v(0.3em)
        set text(size: 14pt, fill: linear-colors.muted-fg)
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
  extra: none,
) = {
  page({
    set align(center + horizon)

    // Main title
    block(
      width: 100%,
      {
        text(
          size: 56pt,
          weight: 700,
          fill: linear-colors.primary,
          title,
        )
      },
    )

    // Subtitle
    if subtitle != none {
      v(0.5em)
      block(
        width: 100%,
        {
          text(
            size: 28pt,
            weight: 400,
            fill: linear-colors.muted-fg,
            subtitle,
          )
        },
      )
    }

    // Divider
    v(2em)
    block(
      width: 40%,
      height: 2pt,
      fill: linear-colors.border-strong,
    )
    v(2em)

    // Author and date
    if author != none or date != none {
      block(
        width: 100%,
        {
          set text(size: 20pt, fill: linear-colors.muted-fg)
          if author != none { author }
          if author != none and date != none [ \ ]
          if date != none { date }
        },
      )
    }

    // Extra info
    if extra != none {
      v(1em)
      block(
        width: 100%,
        text(size: 18pt, fill: linear-colors.muted-fg, extra),
      )
    }
  })
}

// Focus slide (like shadcn's hero sections)
#let focus-slide(body) = {
  page({
    set align(center + horizon)
    set text(size: 64pt, weight: 700, fill: linear-colors.primary)
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

// Callout box (like shadcn alerts)
#let callout(
  body,
  type: "info",
  title: none,
) = {
  let colors = if type == "info" {
    (bg: linear-colors.accent-light, border: linear-colors.accent, icon: "ℹ")
  } else if type == "warning" {
    (bg: rgb("#fef3c7"), border: linear-colors.warning, icon: "⚠")
  } else if type == "success" {
    (bg: rgb("#d1fae5"), border: linear-colors.success, icon: "✓")
  } else if type == "danger" {
    (bg: rgb("#fee2e2"), border: linear-colors.danger, icon: "✕")
  } else {
    (bg: linear-colors.muted, border: linear-colors.border-strong, icon: "•")
  }

  block(
    width: 100%,
    fill: colors.bg,
    stroke: (left: 3pt + colors.border),
    radius: 6pt,
    inset: 1em,
    {
      if title != none {
        text(weight: 600, size: 18pt)[#colors.icon #title]
        v(0.5em)
      } else {
        text(weight: 600, size: 18pt)[#colors.icon ]
      }
      set text(size: 18pt)
      body
    },
  )
}

// Card component (inspired by shadcn cards)
#let card(
  title: none,
  body,
  footer: none,
) = {
  block(
    width: 100%,
    fill: white,
    stroke: 1pt + linear-colors.border,
    radius: 8pt,
    inset: 1.2em,
    {
      if title != none {
        text(size: 22pt, weight: 600, fill: linear-colors.primary, title)
        v(0.8em)
      }
      body
      if footer != none {
        v(0.8em)
        block(
          width: 100%,
          stroke: (top: 1pt + linear-colors.border),
          inset: (top: 0.8em),
          text(size: 16pt, fill: linear-colors.muted-fg, footer),
        )
      }
    },
  )
}

// Badge component
#let badge(body, type: "default") = {
  let colors = if type == "default" {
    (bg: linear-colors.muted, fg: linear-colors.fg)
  } else if type == "accent" {
    (bg: linear-colors.accent-light, fg: linear-colors.accent)
  } else if type == "success" {
    (bg: rgb("#d1fae5"), fg: linear-colors.success)
  } else {
    (bg: linear-colors.muted, fg: linear-colors.fg)
  }

  box(
    fill: colors.bg,
    outset: (x: 6pt, y: 3pt),
    radius: 4pt,
    text(
      size: 14pt,
      weight: 500,
      fill: colors.fg,
      body,
    ),
  )
}

// Outline/table of contents slide
#let outline-slide(title: [Contenido], depth: 2) = {
  slide(title: title)[
    #set text(size: 22pt)

    #show outline.entry: it => {
      let indent = 1.5em * (it.level - 1)

      block(
        width: 100%,
        inset: (left: indent, y: 0.4em),
        {
          if it.level == 1 {
            text(weight: 600, fill: linear-colors.primary, it.body())
          } else {
            text(fill: linear-colors.muted-fg, it.body())
          }

          h(1fr)

          text(
            fill: linear-colors.muted-fg,
            size: 18pt,
            it.page(),
          )
        },
      )

      // Add a subtle divider after level 1 entries
      if it.level == 1 {
        v(0.2em)
        block(
          width: 100%,
          height: 1pt,
          fill: linear-colors.border,
        )
        v(0.2em)
      }
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
