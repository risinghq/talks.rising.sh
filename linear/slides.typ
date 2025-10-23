#import "config.typ": colors, fonts, sizes, spacing, radius

// Title slide - opening slide with branding
#let title-slide(
  title: none,
  subtitle: none,
  author: none,
  date: none,
  logo: none,
) = {
  page({
    set align(center + horizon)

    if logo != none {
      v(-2em)
      logo
      v(2em)
    }

    block(
      width: 100%,
      {
        text(
          size: sizes.hero,
          weight: 600,
          fill: colors.fg,
          title,
        )
      },
    )

    if subtitle != none {
      v(1.2em)
      block(
        width: 90%,
        {
          text(
            size: sizes.h3,
            weight: 400,
            fill: colors.muted,
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
          set text(size: sizes.small, fill: colors.muted, weight: 400)
          if author != none {
            text(weight: 500, fill: colors.fg)[#author]
          }
          if author != none and date != none [ \ ]
          if date != none { date }
        },
      )
    }
  })
}

// Standard content slide
#let slide(
  title: none,
  subtitle: none,
  footer: auto,
  header-align: left,
  body,
) = {
  page({
    // Header section
    if title != none {
      block(
        width: 100%,
        inset: (bottom: 0.3em),
        {
          set align(header-align)
          text(size: sizes.h1, weight: 600, fill: colors.fg, title)
          if subtitle != none {
            v(0.4em)
            text(size: sizes.small, weight: 400, fill: colors.gray-500, subtitle)
          }
        },
      )
      v(spacing.md)
    }

    // Content section - prevent headings from being treated as slide titles
    block(
      width: 100%,
      {
        // Override heading styles within slide content
        show heading.where(level: 1): it => {
          text(size: sizes.h2, weight: 600, fill: colors.fg, it.body)
          v(0.4em)
        }

        show heading.where(level: 2): it => {
          text(size: sizes.h3, weight: 600, fill: colors.fg, it.body)
          v(0.3em)
        }

        show heading.where(level: 3): it => {
          text(size: sizes.body, weight: 600, fill: colors.fg, it.body)
          v(0.3em)
        }

        body
      }
    )

    // Footer section
    if footer != auto and footer != none {
      v(1fr)
      block(
        width: 100%,
        inset: (top: spacing.md),
        stroke: (top: 1pt + colors.gray-200),
        {
          v(spacing.sm)
          set text(size: sizes.tiny, fill: colors.gray-500, weight: 400)
          footer
        },
      )
    }
  })
}

// Focus slide for key messages
#let focus-slide(
  body,
  background: colors.bg,
  foreground: colors.fg,
) = {
  set page(fill: background)
  page({
    set align(center + horizon)
    set text(size: sizes.hero, weight: 600, fill: foreground)
    body
  })
}

// Outline/table of contents slide
#let outline-slide(
  title: [Agenda],
  depth: 2,
) = {
  page({
    block(
      width: 100%,
      inset: (bottom: 0.8em),
      {
        text(size: sizes.h2, weight: 600, fill: colors.fg, title)
      },
    )
    v(spacing.lg)

    set text(size: sizes.small)
    set par(leading: 0.8em)

    outline(
      title: none,
      depth: depth,
      indent: auto,
    )
  })
}

// Section divider slide
#let section-slide(
  title,
  subtitle: none,
  accent-color: colors.accent,
) = {
  page({
    set align(horizon)

    block(
      width: 100%,
      {
        // Accent line
        line(
          length: 60pt,
          stroke: 4pt + accent-color,
        )
        v(spacing.lg)

        text(
          size: sizes.display,
          weight: 600,
          fill: colors.fg,
          title,
        )

        if subtitle != none {
          v(spacing.md)
          text(
            size: sizes.h3,
            weight: 400,
            fill: colors.muted,
            subtitle,
          )
        }
      },
    )
  })
}

// Image slide - full bleed or contained
#let image-slide(
  image,
  caption: none,
  fit: "contain",
) = {
  page({
    set align(center + horizon)

    block(
      width: 100%,
      height: if caption != none { 85% } else { 100% },
      {
        set align(center + horizon)
        image
      }
    )

    if caption != none {
      v(spacing.md)
      set text(size: sizes.small, fill: colors.muted)
      set align(center)
      caption
    }
  })
}

// Side-by-side slide (50/50 split with visual separator)
#let split-slide(
  left,
  right,
  title: none,
  split: 50%,
) = {
  let header-content = if title != none {
    block(
      width: 100%,
      inset: (bottom: 0.8em),
      {
        text(size: sizes.h2, weight: 600, fill: colors.fg, title)
      },
    )
    v(spacing.lg)
  }

  page({
    header-content

    grid(
      columns: (split, 1fr),
      column-gutter: spacing.xxl,
      left,
      right,
    )
  })
}

// Thank you / closing slide
#let thank-you-slide(
  message: [Thank you!],
  contact: none,
  background: colors.accent,
) = {
  set page(fill: background)
  page({
    set align(center + horizon)
    set text(fill: colors.bg)

    text(
      size: sizes.hero,
      weight: 600,
      message,
    )

    if contact != none {
      v(spacing.xxl)
      text(
        size: sizes.body,
        weight: 400,
        contact,
      )
    }
  })
}

// Blank slide with just content (no headers/footers)
#let blank-slide(body) = {
  page(body)
}
