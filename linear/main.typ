#import "config.typ": colors, fonts, radius, sizes, spacing
#import "theme.typ": theme
#import "slides.typ": (
  blank-slide, focus-slide, image-slide, outline-slide, qa-slide, section-slide,
  slide, split-slide, thank-you-slide, title-slide,
)
#import "components.typ": (
  badge, button, callout, card, data-table, divider, feature, highlight,
  icon-box, metric, progress, quote, status,
)
#import "layouts.typ": grid-layout, three-columns, two-columns

// Re-export slide types
#let blank-slide = blank-slide
#let focus-slide = focus-slide
#let image-slide = image-slide
#let outline-slide = outline-slide
#let qa-slide = qa-slide
#let section-slide = section-slide
#let slide = slide
#let split-slide = split-slide
#let thank-you-slide = thank-you-slide
#let title-slide = title-slide

// Re-export components
#let badge = badge
#let button = button
#let callout = callout
#let card = card
#let divider = divider
#let feature = feature
#let highlight = highlight
#let icon-box = icon-box
#let metric = metric
#let progress = progress
#let quote = quote
#let status = status

// Re-export layouts
#let grid-layout = grid-layout
#let three-columns = three-columns
#let two-columns = two-columns
