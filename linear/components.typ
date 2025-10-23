#import "config.typ": colors, fonts, radius, sizes, spacing

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
    stroke: (
      left: 2pt + border-color,
      rest: 0.75pt + colors.gray-200.lighten(50%),
    ),
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
          text(weight: 600, size: sizes.small, fill: colors.gray-600)[#title]
        )
        v(0.4em)
      }
      set text(size: sizes.small, fill: colors.gray-600, weight: 400)
      set par(leading: 0.65em)
      body
    },
  )
}

#let card(title: none, body, footer: none, highlight: false) = {
  block(
    width: 100%,
    fill: if highlight { colors.gray-50 } else { colors.bg },
    stroke: 0.75pt + colors.border,
    radius: radius.md,
    inset: (x: 1.5em, y: 1.3em),
    breakable: false,
    {
      if title != none {
        text(size: sizes.h2, weight: 600, fill: colors.fg, title)
        v(0.4em)
      }
      set text(size: sizes.small, fill: colors.gray-600, weight: 400)
      set par(leading: 0.65em)
      body
      if footer != none {
        v(0.7em)
        line(length: 100%, stroke: 0.75pt + colors.gray-200)
        v(0.5em)
        text(size: sizes.small, fill: colors.gray-400, weight: 400, footer)
      }
    },
  )
}

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
    text(size: sizes.body, weight: 500, fill: text-color, body),
  )
}

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
    text(size: sizes.small, weight: 500, fill: text-color, body),
  )
}

#let divider(space: spacing.lg) = {
  v(space)
  line(length: 100%, stroke: 0.75pt + colors.border)
  v(space)
}

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
      circle(radius: 3pt, fill: dot-color),
      text(size: sizes.body, fill: colors.fg, label),
    ),
  )
}

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

#let highlight(body) = {
  box(
    fill: colors.warning-bg,
    inset: (x: 0.4em, y: 0.2em),
    radius: radius.sm,
    baseline: 15%,
    text(fill: colors.warning.darken(20%), weight: 500, body),
  )
}

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

#let feature(body) = {
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.7em,
    align: (horizon, top),
    text(size: sizes.body, fill: colors.success, weight: 600)[✓],
    text(size: sizes.small, fill: colors.fg)[#body],
  )
}

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
