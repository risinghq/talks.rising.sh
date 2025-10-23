#import "config.typ": colors, fonts, sizes

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
          fill: colors.fg,
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
          set text(size: sizes.small, fill: colors.muted)
          if author != none { author }
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
  body,
) = {
  let header-content = if title != none {
    block(
      width: 100%,
      inset: (bottom: 0.6em),
      {
        text(size: sizes.h2, weight: 600, fill: colors.fg, title)
        if subtitle != none {
          v(0.3em)
          text(size: sizes.small, weight: 400, fill: colors.muted, subtitle)
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
      stroke: (top: 0.5pt + colors.border),
      {
        v(0.4em)
        set text(size: sizes.caption, fill: colors.muted)
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

// Focus slide for key messages
#let focus-slide(body) = {
  page({
    set align(center + horizon)
    set text(size: 48pt, weight: 600, fill: colors.fg)
    body
  })
}

// Outline/table of contents slide
#let outline-slide(title: [Contents], depth: 2) = {
  slide(title: title)[
    #set text(size: sizes.body)

    #show outline.entry: it => {
      let indent = 1.5em * (it.level - 1)

      block(
        width: 100%,
        inset: (left: indent, y: 0.5em),
        {
          text(weight: if it.level == 1 { 600 } else { 400 }, it.body)
          h(1fr)
          text(fill: colors.muted, it.page)
        },
      )
    }

    #outline(depth: depth)
  ]
}
