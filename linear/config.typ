#let colors = (
  // Primary brand colors - Linear's signature purple
  magic-blue: rgb("#5e6ad2"), // Primary brand color
  mercury-white: rgb("#f9fafb"), // Very light gray for backgrounds
  nordic-gray: rgb("#1f2937"), // Dark gray for text (lighter than before)
  // Semantic colors for UI - ultra minimal
  bg: rgb("#ffffff"), // Pure white background
  fg: rgb("#18181b"), // Near black text
  muted: rgb("#6b7280"), // Muted gray for secondary text
  border: rgb("#e5e7eb"), // Subtle border color
  // Accent variations
  accent: rgb("#5e6ad2"),
  accent-bg: rgb("#f0f1ff"), // Very light purple tint
  accent-hover: rgb("#4c5bc4"),
  // Status colors - muted versions
  success: rgb("#10b981"),
  success-bg: rgb("#f0fdf4"),
  warning: rgb("#f59e0b"),
  warning-bg: rgb("#fffbeb"),
  danger: rgb("#ef4444"),
  danger-bg: rgb("#fef2f2"),
  info: rgb("#3b82f6"),
  info-bg: rgb("#eff6ff"),
  // Gray scale - Linear's refined palette
  gray-50: rgb("#f9fafb"),
  gray-100: rgb("#f3f4f6"),
  gray-200: rgb("#e5e7eb"),
  gray-300: rgb("#d1d5db"),
  gray-400: rgb("#9ca3af"),
  gray-500: rgb("#6b7280"),
  gray-600: rgb("#4b5563"),
  gray-700: rgb("#374151"),
  gray-800: rgb("#1f2937"),
  gray-900: rgb("#111827"),
  // Code block colors - LIGHT theme like Linear
  code-bg: rgb("#f9fafb"), // Very light gray background
  code-border: rgb("#e5e7eb"), // Subtle border
  code-text: rgb("#1f2937"), // Dark gray text for code
  code-keyword: rgb("#9333ea"), // Purple for keywords
  code-string: rgb("#059669"), // Green for strings
  code-number: rgb("#dc2626"), // Red for numbers
  code-comment: rgb("#6b7280"), // Gray for comments
  code-function: rgb("#2563eb"), // Blue for functions
)

#let fonts = (
  sans: "Geist",
  mono: "Geist Mono",
)

// Typography scale - refined for minimal aesthetic
#let sizes = (
  // Headings - more restrained
  h1: 26pt,
  h2: 20pt,
  h3: 17pt,
  h4: 15pt,
  // Body text
  body: 15pt,
  small: 14pt,
  tiny: 12pt,
  caption: 11pt,
  // Special sizes
  display: 38pt,
  hero: 44pt,
)

// Spacing scale (8pt grid system) - Linear's minimal spacing
#let spacing = (
  xs: 0.25em,
  sm: 0.5em,
  md: 1em,
  lg: 1.5em,
  xl: 2em,
  xxl: 3em,
)

// Border radius scale - more subtle
#let radius = (
  sm: 4pt,
  md: 6pt,
  lg: 8pt,
  xl: 12pt,
  full: 999pt,
)
