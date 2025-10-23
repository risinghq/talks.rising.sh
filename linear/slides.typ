#import "config.typ": colors, fonts, radius, sizes, spacing

// State to track slide titles for outline
#let slide-titles = state("slide-titles", ())

// Title slide - opening slide with minimal branding
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
      v(1em)
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

    v(2.5em)

    if author != none or date != none {
      block(
        width: 100%,
        {
          set text(size: sizes.small, fill: colors.muted, weight: 400)
          if author != none {
            text(weight: 500, fill: colors.gray-600)[#author]
          }
          if author != none and date != none [ \ ]
          if date != none { date }
        },
      )
    }
  })
}

// Standard content slide - ultra minimal like Linear
#let slide(
  title: none,
  subtitle: none,
  footer: auto,
  header-align: left,
  body,
) = {
  // Register this slide's title for the outline
  if title != none {
    slide-titles.update(t => {
      t.push(title)
      t
    })
  }

  page({
    // Header section - clean and minimal
    if title != none {
      block(
        width: 100%,
        inset: (bottom: 0.2em),
        {
          set align(header-align)
          text(size: sizes.h1, weight: 600, fill: colors.fg, title)
          if subtitle != none {
            v(0.3em)
            text(
              size: sizes.small,
              weight: 400,
              fill: colors.gray-500,
              subtitle,
            )
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
          v(0.3em)
        }

        show heading.where(level: 2): it => {
          text(size: sizes.h3, weight: 600, fill: colors.fg, it.body)
          v(0.25em)
        }

        show heading.where(level: 3): it => {
          text(size: sizes.body, weight: 600, fill: colors.fg, it.body)
          v(0.25em)
        }

        body
      },
    )

    // Footer section - subtle
    if footer != auto and footer != none {
      v(1fr)
      block(
        width: 100%,
        inset: (top: spacing.sm),
        stroke: (top: 0.75pt + colors.gray-200),
        {
          v(spacing.sm)
          set text(size: sizes.tiny, fill: colors.gray-400, weight: 400)
          footer
        },
      )
    }
  })
}

// Focus slide for key messages - minimal emphasis
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

// Outline/table of contents slide - clean list
#let outline-slide(
  title: [Agenda],
) = {
  page({
    block(
      width: 100%,
      inset: (bottom: 0.6em),
      {
        text(size: sizes.h2, weight: 600, fill: colors.fg, title)
      },
    )
    v(spacing.lg)

    set text(size: sizes.body, fill: colors.fg)
    set par(leading: 0.7em)

    // Display collected slide titles
    context {
      let titles = slide-titles.final()
      if titles.len() > 0 {
        for (i, slide-title) in titles.enumerate() {
          grid(
            columns: (auto, 1fr),
            column-gutter: 0.8em,
            text(
              size: sizes.small,
              fill: colors.gray-400,
              weight: 500,
            )[#(i + 1).],
            text(weight: 400)[#slide-title],
          )
          if i < titles.len() - 1 {
            v(0.5em)
          }
        }
      } else {
        text(fill: colors.gray-400)[No slides with titles found]
      }
    }
  })
}

// Section divider slide - minimal with accent line
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
        // Accent line - thin and elegant
        line(
          length: 50pt,
          stroke: 3pt + accent-color,
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
      },
    )

    if caption != none {
      v(spacing.md)
      set text(size: sizes.small, fill: colors.muted, weight: 400)
      set align(center)
      caption
    }
  })
}

// Side-by-side slide (customizable split with minimal gap)
#let split-slide(
  left,
  right,
  title: none,
  split: 50%,
) = {
  let header-content = if title != none {
    block(
      width: 100%,
      inset: (bottom: 0.6em),
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
      column-gutter: spacing.xl,
      left, right,
    )
  })
}

// Thank you / closing slide - clean and minimal
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
      v(spacing.xl)
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

// Q&A / Questions slide - minimal and inviting
#let qa-slide(
  question: [Questions?],
  subtitle: [Feel free to reach out],
) = {
  page({
    set align(center + horizon)

    text(
      size: sizes.display,
      weight: 600,
      fill: colors.fg,
      question,
    )

    if subtitle != none {
      v(spacing.lg)
      text(
        size: sizes.body,
        weight: 400,
        fill: colors.gray-500,
        subtitle,
      )
    }
  })
}

// Comparison slide - side-by-side comparison with headers
#let comparison-slide(
  title: none,
  left-title,
  left-content,
  right-title,
  right-content,
) = {
  page({
    if title != none {
      block(
        width: 100%,
        inset: (bottom: 0.6em),
        {
          text(size: sizes.h2, weight: 600, fill: colors.fg, title)
        },
      )
      v(spacing.lg)
    }

    grid(
      columns: (1fr, 1fr),
      column-gutter: spacing.xl,
      // Left column
      block({
        text(size: sizes.h3, weight: 600, fill: colors.fg)[#left-title]
        v(spacing.md)
        left-content
      }),
      // Right column
      block({
        text(size: sizes.h3, weight: 600, fill: colors.fg)[#right-title]
        v(spacing.md)
        right-content
      }),
    )
  })
}

// List slide - formatted list with optional title
#let list-slide(
  title: none,
  items,
) = {
  page({
    if title != none {
      block(
        width: 100%,
        inset: (bottom: 0.6em),
        {
          text(size: sizes.h2, weight: 600, fill: colors.fg, title)
        },
      )
      v(spacing.lg)
    }

    set text(size: sizes.body, fill: colors.fg)
    set list(marker: ([•], [◦], [▸]), spacing: 0.6em)

    items
  })
}
