#import "config.typ": colors, fonts, sizes, spacing, radius

// Callout box for highlighting information
#let callout(body, title: none, type: "default") = {
  let (bg-color, border-color, icon) = if type == "success" {
    (colors.success-bg, colors.success.lighten(10%), [✓])
  } else if type == "warning" {
    (colors.warning-bg, colors.warning, [⚠])
  } else if type == "danger" {
    (colors.danger-bg, colors.danger, [✕])
  } else if type == "info" {
    (colors.info-bg, colors.info, [ℹ])
  } else {
    (colors.gray-50, colors.gray-400, none)
  }

  block(
    width: 100%,
    fill: bg-color,
    stroke: (left: 2.5pt + border-color.lighten(10%)),
    radius: radius.md,
    inset: (x: 1.2em, y: 1em),
    breakable: false,
    {
      if title != none {
        grid(
          columns: if icon != none { (auto, 1fr) } else { (1fr,) },
          column-gutter: 0.5em,
          align: (horizon, horizon),
          if icon != none {
            text(weight: 600, size: sizes.tiny, fill: border-color)[#icon]
          },
          text(weight: 600, size: sizes.tiny, fill: colors.gray-700)[#title]
        )
        v(0.5em)
      }
      set text(size: sizes.small, fill: colors.gray-600, weight: 400)
      set par(leading: 0.7em)
      body
    },
  )
}

// Card component for structured content
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
    stroke: 0.5pt + colors.gray-200.lighten(20%),
    radius: radius.lg,
    inset: (x: 1.8em, y: 1.5em),
    breakable: false,
    {
      // Title
      if title != none {
        text(size: sizes.body, weight: 600, fill: colors.fg, title)
        v(0.5em)
      }

      // Body content
      set text(size: sizes.small, fill: colors.gray-600, weight: 400)
      set par(leading: 0.7em)
      body

      // Footer
      if footer != none {
        v(0.8em)
        line(length: 100%, stroke: 0.5pt + colors.gray-200.lighten(30%))
        v(0.6em)
        text(size: sizes.tiny, fill: colors.gray-400, weight: 400, footer)
      }
    },
  )
}

// Badge for inline labels
#let badge(body, type: "default") = {
  let (bg-color, text-color) = if type == "accent" {
    (colors.accent, colors.bg)
  } else if type == "success" {
    (colors.success-bg, colors.success.darken(10%))
  } else if type == "warning" {
    (colors.warning-bg, colors.warning.darken(10%))
  } else if type == "danger" {
    (colors.danger-bg, colors.danger.darken(10%))
  } else if type == "info" {
    (colors.info-bg, colors.info.darken(10%))
  } else {
    (colors.gray-100, colors.gray-700)
  }

  box(
    fill: bg-color,
    inset: (x: 0.4em, y: 0.2em),
    radius: radius.sm,
    baseline: 12%,
    text(
      size: sizes.caption,
      weight: 500,
      fill: text-color,
      body,
    ),
  )
}

// Button component
#let button(body, type: "primary") = {
  let (bg-color, text-color, border-color) = if type == "primary" {
    (colors.accent, colors.bg, colors.accent)
  } else if type == "secondary" {
    (colors.bg, colors.fg, colors.gray-300)
  } else if type == "danger" {
    (colors.danger, colors.bg, colors.danger)
  } else {
    (colors.gray-100, colors.fg, colors.gray-200)
  }

  box(
    fill: bg-color,
    stroke: 1pt + border-color,
    inset: (x: 1.2em, y: 0.6em),
    radius: radius.md,
    baseline: 15%,
    text(
      size: sizes.small,
      weight: 500,
      fill: text-color,
      body,
    ),
  )
}

// Divider component
#let divider(space: spacing.lg) = {
  v(space)
  line(length: 100%, stroke: 1pt + colors.border)
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
        radius: 4pt,
        fill: dot-color,
      ),
      text(size: sizes.small, fill: colors.fg, label)
    )
  )
}

// Code block with syntax highlighting style
#let code-block(body, lang: none) = {
  block(
    width: 100%,
    fill: colors.nordic-gray,
    stroke: none,
    radius: radius.md,
    inset: 1.2em,
    {
      if lang != none {
        text(
          size: sizes.tiny,
          fill: colors.gray-400,
          weight: 500,
        )[#lang]
        v(0.5em)
      }
      set text(
        font: fonts.mono,
        size: sizes.tiny,
        fill: colors.mercury-white,
      )
      body
    },
  )
}

// Quote/blockquote component
#let quote(body, author: none) = {
  block(
    width: 100%,
    inset: (left: 1.2em, y: 0.8em),
    stroke: (left: 3pt + colors.accent),
    {
      set text(size: sizes.body, fill: colors.fg, style: "italic")
      body
      if author != none {
        v(0.5em)
        text(size: sizes.small, fill: colors.muted, weight: 500)[— #author]
      }
    }
  )
}

// Highlight box (for key information)
#let highlight(body) = {
  box(
    fill: rgb("#fff7ed"),
    inset: (x: 0.4em, y: 0.2em),
    radius: radius.sm,
    baseline: 15%,
    text(fill: rgb("#ea580c"), weight: 500, body)
  )
}

// Icon box (for emoji or symbols)
#let icon-box(icon, size: 48pt, bg: colors.accent-bg) = {
  box(
    width: size * 1.5,
    height: size * 1.5,
    fill: bg,
    radius: radius.lg,
    {
      set align(center + horizon)
      text(size: size, icon)
    }
  )
}

// Tag (similar to badge but more compact)
#let tag(body, color: colors.accent) = {
  box(
    fill: color.lighten(80%),
    inset: (x: 6pt, y: 2pt),
    radius: radius.sm,
    baseline: 15%,
    text(
      size: sizes.tiny,
      weight: 500,
      fill: color.darken(20%),
      body,
    ),
  )
}

// Progress bar
#let progress(value, total: 100, color: colors.accent) = {
  let percentage = calc.min(100, (value / total) * 100)

  stack(
    dir: ltr,
    block(
      width: 100%,
      height: 8pt,
      fill: colors.gray-200,
      radius: radius.full,
      box(
        width: percentage * 1%,
        height: 100%,
        fill: color,
        radius: radius.full,
      )
    )
  )
}

// Step indicator (for multi-step processes)
#let step(number, title, completed: false) = {
  let circle-color = if completed { colors.success } else { colors.accent }
  let circle-content = if completed { [✓] } else { str(number) }

  grid(
    columns: (auto, 1fr),
    column-gutter: 1em,
    align: (horizon, horizon),
    box(
      width: 32pt,
      height: 32pt,
      fill: circle-color,
      radius: radius.full,
      {
        set align(center + horizon)
        text(size: sizes.small, fill: colors.bg, weight: 600)[#circle-content]
      }
    ),
    text(size: sizes.body, weight: 500, fill: colors.fg)[#title]
  )
}

// Feature list item (with checkmark)
#let feature(body) = {
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.8em,
    align: (horizon, top),
    text(size: sizes.body, fill: colors.success, weight: 600)[✓],
    text(size: sizes.small, fill: colors.fg)[#body]
  )
}

// Metric display (for showcasing numbers)
#let metric(value, label, change: none) = {
  block(
    width: 100%,
    {
      text(size: sizes.h1, weight: 600, fill: colors.fg)[#value]
      v(0.3em)
      text(size: sizes.small, fill: colors.muted)[#label]
      if change != none {
        v(0.3em)
        let change-color = if type(change) == str and change.starts-with("+") {
          colors.success
        } else if type(change) == str and change.starts-with("-") {
          colors.danger
        } else {
          colors.muted
        }
        text(size: sizes.tiny, fill: change-color, weight: 500)[#change]
      }
    }
  )
}
