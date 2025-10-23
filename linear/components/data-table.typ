#import "../config.typ": colors, sizes

#let data-table(headers: (), rows: (), striped: true, compact: false) = {
  let cell-padding = if compact { (x: 0em, y: 0.5em) } else {
    (x: 0em, y: 0.75em)
  }
  let header-size = if compact { sizes.small } else { sizes.body }
  let body-size = if compact { sizes.small } else { sizes.body }

  block(
    width: 100%,
    {
      table(
        columns: headers.len(),
        inset: 0pt,
        stroke: none,
        // Header row
        ..headers.map(header => {
          block(
            inset: cell-padding,
            width: 100%,
            text(
              size: header-size,
              weight: 600,
              fill: colors.fg,
              header,
            ),
          )
        }),
        // Data rows
        ..rows
          .flatten()
          .map(cell => {
            block(
              inset: cell-padding,
              width: 100%,
              stroke: (top: 0.5pt + colors.gray-200),
              text(
                size: body-size,
                weight: 400,
                fill: colors.gray-700,
                cell,
              ),
            )
          })
      )
    },
  )
}
