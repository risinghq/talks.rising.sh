#import "config.typ": colors, fonts, radius, sizes, spacing

#let slide-titles = state("slide-titles", ())
#let slide-counter = counter("slide-num")


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

    block(width: 100%, text(
      size: sizes.hero,
      weight: 600,
      fill: colors.fg,
      title,
    ))

    if subtitle != none {
      v(spacing.md)
      block(width: 90%, text(
        size: sizes.h2,
        weight: 400,
        fill: colors.muted,
        subtitle,
      ))
    }

    v(2.5em)

    if author != none or date != none {
      block(
        width: 100%,
        {
          set text(size: sizes.body, fill: colors.muted, weight: 400)
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

#let slide(
  title: none,
  subtitle: none,
  footer: auto,
  header-align: left,
  body,
) = {
  if title != none {
    slide-titles.update(t => {
      t.push(title)
      t
    })
  }

  page({
    /*
        place(left + horizon, dx: -1.5em, {
          line(
            start: (0pt, 0%),
            end: (0pt, 130%),
            stroke: (
              paint: colors.gray-200,
              thickness: 0.5pt,
              dash: (4pt, 4.5pt),
            ),
          )
        })

        place(right + horizon, dx: 1.5em, {
          line(
            start: (0pt, 0%),
            end: (0pt, 130%),
            stroke: (
              paint: colors.gray-200,
              thickness: 0.5pt,
              dash: (4pt, 4.5pt),
            ),
          )
        })
    */
    if title != none {
      slide-counter.step()
      block(
        width: 100%,
        inset: (bottom: 0.2em),
        {
          set align(header-align)
          context {
            let num = slide-counter.get().first()
            if subtitle != none {
              [#text(size: sizes.h1, weight: 500, fill: colors.gray-500)[#title]
              #text(size: sizes.h1, weight: 500, fill: colors.gray-400)[#" / "]
              #text(size: sizes.h1, weight: 700, fill: colors.fg)[#subtitle]
              #label("slide-" + str(num))]
            } else {
              [#text(size: sizes.h1, weight: 700, fill: colors.fg, title)
              #label("slide-" + str(num))]
            }
          }
        },
      )
      v(spacing.md)
    }

    block(
      width: 100%,
      {
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

    if footer != auto and footer != none {
      v(1fr)
      block(
        width: 100%,
        inset: (top: spacing.sm),
        stroke: (top: 0.75pt + colors.gray-200),
        {
          v(spacing.sm)
          set text(size: sizes.small, fill: colors.gray-400, weight: 400)
          footer
        },
      )
    }
  })
}

#let focus-slide(
  body,
  background: colors.bg,
  foreground: colors.fg,
) = {
  set page(fill: background, margin: 0pt)
  page({
    set align(center + horizon)
    set text(size: sizes.hero, weight: 600, fill: foreground)
    body
  })
}

#let outline-slide(title: [Agenda]) = {
  page({
    block(
      width: 100%,
      inset: (bottom: 0.6em),
      text(size: sizes.h1, weight: 700, fill: colors.fg, title),
    )
    v(spacing.lg)

    set text(size: sizes.body, fill: colors.fg)
    set par(leading: 0.7em, spacing: 0.6em)

    context {
      let titles = slide-titles.final()
      if titles.len() > 0 {
        // Split titles into two columns
        let mid = calc.ceil(titles.len() / 2)
        let first-col = titles.slice(0, mid)
        let second-col = titles.slice(mid)

        grid(
          columns: (1fr, 1fr),
          column-gutter: 2em,
          // First column
          {
            for (i, slide-title) in first-col.enumerate() {
              grid(
                columns: (auto, 1fr),
                column-gutter: 0.8em,
                text(
                  size: sizes.small,
                  fill: colors.gray-400,
                  weight: 500,
                )[#(i + 1).],
                link(
                  label("slide-" + str(i + 1)),
                  text(weight: 400, fill: colors.accent)[#slide-title]
                ),
              )
              if i < first-col.len() - 1 {
                v(0.5em)
              }
            }
          },
          // Second column
          {
            for (i, slide-title) in second-col.enumerate() {
              let idx = mid + i
              grid(
                columns: (auto, 1fr),
                column-gutter: 0.8em,
                text(
                  size: sizes.small,
                  fill: colors.gray-400,
                  weight: 500,
                )[#(idx + 1).],
                link(
                  label("slide-" + str(idx + 1)),
                  text(weight: 400, fill: colors.accent)[#slide-title]
                ),
              )
              if i < second-col.len() - 1 {
                v(0.5em)
              }
            }
          },
        )
      } else {
        text(fill: colors.gray-400)[No slides with titles found]
      }
    }
  })
}

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
        line(length: 50pt, stroke: 3pt + accent-color)
        v(spacing.lg)
        text(size: sizes.display, weight: 600, fill: colors.fg, title)

        if subtitle != none {
          v(spacing.md)
          text(size: sizes.h3, weight: 400, fill: colors.muted, subtitle)
        }
      },
    )
  })
}

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
      text(size: sizes.h1, weight: 700, fill: colors.fg, title),
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

#let thank-you-slide(
  message: [Thank you!],
  contact: none,
  background: colors.accent,
) = {
  set page(fill: background)
  page({
    set align(center + horizon)
    set text(fill: colors.bg)

    text(size: sizes.hero, weight: 600, message)

    if contact != none {
      v(spacing.xl)
      text(size: sizes.body, weight: 400, contact)
    }
  })
}

#let blank-slide(body) = {
  page(body)
}

#let qa-slide(
  question: [Questions?],
  subtitle: [Feel free to reach out],
) = {
  page({
    set align(center + horizon)

    block(width: 100%, text(
      size: sizes.display,
      weight: 600,
      fill: colors.fg,
      question,
    ))

    if subtitle != none {
      v(spacing.sm)
      block(width: 90%, text(
        size: sizes.body,
        weight: 400,
        fill: colors.gray-500,
        subtitle,
      ))
    }
  })
}
