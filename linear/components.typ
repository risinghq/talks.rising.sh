#import "config.typ": colors, fonts, radius, sizes, spacing

// Callout box for highlighting information - Linear's minimal style
#let callout(body, title: none, type: "default") = {
  let (bg-color, border-color, icon) = if type == "success" {
    (colors.success-bg, colors.success, [✓])
  } else if type == "warning" {
    (colors.warning-bg, colors.warning, [⚠])
  } else if type == "danger" {
    (colors.danger-bg, colors.danger, [✕])
  } else if type == "info" {
    (colors.info-bg, colors.info, [ℹ])
  } else {
    (colors.gray-50, colors.gray-300, none)
  }

  block(
    width: 100%,
    fill: bg-color,
    stroke: (left: 2pt + border-color),
    radius: radius.sm,
    inset: (x: 1em, y: 0.9em),
    breakable: false,
    {
      if title != none {
        grid(
          columns: if icon != none { (auto, 1fr) } else { (1fr,) },
          column-gutter: 0.5em,
          align: (horizon, horizon),
          if icon != none {
            text(weight: 600, size: sizes.small, fill: border-color)[#icon]
          },
          text(weight: 600, size: sizes.small, fill: colors.gray-700)[#title]
        )
        v(0.4em)
      }
      set text(size: sizes.small, fill: colors.gray-600, weight: 400)
      set par(leading: 0.65em)
      body
    },
  )
}

// Card component - ultra minimal like Linear's docs
#let card(
  title: none,
  body,
  footer: none,
  highlight: false,
  min-height: none,
) = {
  block(
    width: 100%,
    height: if min-height != none { min-height } else { auto },
    fill: if highlight { colors.gray-50 } else { colors.bg },
    stroke: 0.75pt + colors.border,
    radius: radius.md,
    inset: (x: 1.5em, y: 1.3em),
    breakable: false,
    {
      // Title
      if title != none {
        text(size: sizes.body, weight: 600, fill: colors.fg, title)
        v(0.4em)
      }

      // Body content
      set text(size: sizes.small, fill: colors.gray-600, weight: 400)
      set par(leading: 0.65em)
      body

      // Footer
      if footer != none {
        v(0.7em)
        line(length: 100%, stroke: 0.75pt + colors.gray-200)
        v(0.5em)
        text(size: sizes.tiny, fill: colors.gray-400, weight: 400, footer)
      }
    },
  )
}

// Badge for inline labels - minimal rounded style
#let badge(body, type: "default") = {
  let (bg-color, text-color) = if type == "accent" {
    (colors.accent, colors.bg)
  } else if type == "success" {
    (colors.success-bg, colors.success.darken(15%))
  } else if type == "warning" {
    (colors.warning-bg, colors.warning.darken(15%))
  } else if type == "danger" {
    (colors.danger-bg, colors.danger.darken(15%))
  } else if type == "info" {
    (colors.info-bg, colors.info.darken(15%))
  } else {
    (colors.gray-100, colors.gray-600)
  }

  box(
    fill: bg-color,
    inset: (x: 0.5em, y: 0.25em),
    radius: radius.sm,
    baseline: 13%,
    text(
      size: sizes.caption,
      weight: 500,
      fill: text-color,
      body,
    ),
  )
}

// Button component - Linear's clean button style
#let button(body, type: "primary") = {
  let (bg-color, text-color, border-color) = if type == "primary" {
    (colors.accent, colors.bg, colors.accent)
  } else if type == "secondary" {
    (colors.bg, colors.fg, colors.border)
  } else if type == "danger" {
    (colors.danger, colors.bg, colors.danger)
  } else {
    (colors.gray-50, colors.fg, colors.gray-200)
  }

  box(
    fill: bg-color,
    stroke: 0.75pt + border-color,
    inset: (x: 1em, y: 0.5em),
    radius: radius.sm,
    baseline: 15%,
    text(
      size: sizes.small,
      weight: 500,
      fill: text-color,
      body,
    ),
  )
}

// Divider component - very subtle
#let divider(space: spacing.lg) = {
  v(space)
  line(length: 100%, stroke: 0.75pt + colors.border)
  v(space)
}

// Status indicator (dot with label)
#let status(label, type: "default") = {
  let dot-color = if type == "success" {
    colors.success
  } else if type == "warning" {
    colors.warning
  } else if type == "danger" {
    colors.danger
  } else if type == "active" {
    colors.accent
  } else {
    colors.gray-400
  }

  box(
    grid(
      columns: (auto, 1fr),
      column-gutter: 0.5em,
      align: (horizon, horizon),
      circle(
        radius: 3pt,
        fill: dot-color,
      ),
      text(size: sizes.small, fill: colors.fg, label),
    ),
  )
}

// Code block with language label - light theme
#let code-block(body, lang: none) = {
  block(
    width: 100%,
    fill: colors.code-bg,
    stroke: 0.75pt + colors.code-border,
    radius: radius.md,
    inset: 1.2em,
    {
      if lang != none {
        text(
          size: sizes.tiny,
          fill: colors.gray-500,
          weight: 500,
        )[#lang]
        v(0.5em)
      }
      set text(
        font: fonts.mono,
        size: sizes.tiny,
        fill: colors.code-text,
      )
      body
    },
  )
}

// Quote/blockquote component - minimal accent
#let quote(body, author: none) = {
  block(
    width: 100%,
    inset: (left: 1em, y: 0.7em),
    stroke: (left: 2.5pt + colors.accent),
    {
      set text(size: sizes.body, fill: colors.fg, style: "italic", weight: 400)
      body
      if author != none {
        v(0.4em)
        text(
          size: sizes.small,
          fill: colors.muted,
          weight: 500,
          style: "normal",
        )[— #author]
      }
    },
  )
}

// Highlight box (for key information) - subtle background
#let highlight(body) = {
  box(
    fill: colors.warning-bg,
    inset: (x: 0.4em, y: 0.2em),
    radius: radius.sm,
    baseline: 15%,
    text(fill: colors.warning.darken(20%), weight: 500, body),
  )
}

// Icon box (for emoji or symbols) - minimal rounded square
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

// Tag (similar to badge but more compact)
#let tag(body, color: colors.accent) = {
  box(
    fill: color.lighten(85%),
    inset: (x: 0.4em, y: 0.15em),
    radius: radius.sm,
    baseline: 15%,
    text(
      size: sizes.tiny,
      weight: 500,
      fill: color.darken(15%),
      body,
    ),
  )
}

// Progress bar - minimal flat design
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

// Step indicator (for multi-step processes) - Linear style
#let step(number, title, completed: false) = {
  let circle-color = if completed { colors.success } else { colors.accent }
  let circle-content = if completed { [✓] } else { str(number) }

  grid(
    columns: (auto, 1fr),
    column-gutter: 0.9em,
    align: (horizon, horizon),
    box(
      width: 28pt,
      height: 28pt,
      fill: circle-color,
      radius: radius.full,
      {
        set align(center + horizon)
        text(size: sizes.small, fill: colors.bg, weight: 600)[#circle-content]
      },
    ),
    text(size: sizes.body, weight: 500, fill: colors.fg)[#title],
  )
}

// Feature list item (with checkmark) - clean spacing
#let feature(body) = {
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.7em,
    align: (horizon, top),
    text(size: sizes.body, fill: colors.success, weight: 600)[✓],
    text(size: sizes.small, fill: colors.fg)[#body],
  )
}

// Metric display (for showcasing numbers) - minimal style
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
        text(size: sizes.tiny, fill: change-color, weight: 500)[#change]
      }
    },
  )
}

// Info box - subtle bordered box for additional context
#let info-box(body, icon: [ℹ]) = {
  block(
    width: 100%,
    fill: colors.gray-50,
    stroke: 0.75pt + colors.border,
    radius: radius.sm,
    inset: (x: 1em, y: 0.8em),
    {
      grid(
        columns: (auto, 1fr),
        column-gutter: 0.6em,
        align: (top, top),
        text(size: sizes.small, fill: colors.gray-500)[#icon],
        {
          set text(size: sizes.small, fill: colors.gray-600, weight: 400)
          set par(leading: 0.65em)
          body
        },
      )
    },
  )
}

// Link card - for showcasing external resources
#let link-card(title, description: none, url: none) = {
  block(
    width: 100%,
    fill: colors.bg,
    stroke: 0.75pt + colors.border,
    radius: radius.md,
    inset: (x: 1.2em, y: 1em),
    {
      text(size: sizes.body, weight: 600, fill: colors.fg)[#title]
      if description != none {
        v(0.3em)
        text(
          size: sizes.small,
          fill: colors.gray-600,
          weight: 400,
        )[#description]
      }
      if url != none {
        v(0.5em)
        text(size: sizes.tiny, fill: colors.accent, weight: 500)[#url →]
      }
    },
  )
}
