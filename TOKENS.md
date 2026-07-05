# Repeto Design Tokens

This file is the single source of truth for design tokens used across the app.
All color, spacing, and radius values in Swift code and asset generation scripts must reference these tokens.

## Colors

### Accent

The single source of truth is the `AccentColor` asset in `Repeto/Assets.xcassets`.
`DesignSystem.accent` (and `.accent` in views) resolves to it via `Color.accentColor`.

| Token | Light | Dark | Usage |
| --- | --- | --- | --- |
| `accent` | `#007AFF` (iOS system blue) | `#0A84FF` | Primary action buttons, icons |

### Task Status

| Token | Value | Usage |
| --- | --- | --- |
| `status.overdue` | `.red` (system) | Overdue task highlighting |
| `status.today` | `.orange` (system) | Today's task highlighting |
| `status.upcoming` | `.primary` (system) | Upcoming tasks (default) |

### Semantic

| Token | Value | Usage |
| --- | --- | --- |
| `secondary` | `.secondary` (system) | Secondary text, hints |
| `destructive` | `.red` (system) | Delete actions, error messages |

## Spacing

All spacing values are in points (pt).

| Token | Value | Usage |
| --- | --- | --- |
| `spacing.xs` | `4` | Tight gaps (e.g., icon-to-label) |
| `spacing.sm` | `8` | Small gaps (e.g., between form fields) |
| `spacing.md` | `16` | Default padding |
| `spacing.lg` | `20` | Section spacing, empty state |
| `spacing.xl` | `32` | Large section breaks |

## Corner Radius

| Token | Value | Usage |
| --- | --- | --- |
| `radius.sm` | `8` | Small cards, tags |
| `radius.md` | `12` | Standard cards |
| `radius.lg` | `16` | Large cards, sheets |

## Icon Sizes

| Token | Value | Usage |
| --- | --- | --- |
| `iconSize.sm` | `20` | Toolbar icons |
| `iconSize.md` | `44` | Standard icons |
| `iconSize.lg` | `80` | Empty state illustration |

## Typography

Follow iOS Human Interface Guidelines. Use system fonts at system-defined sizes.

| Token | SwiftUI | Usage |
| --- | --- | --- |
| `text.largeTitle` | `.largeTitle` | Screen titles |
| `text.title2` | `.title2` | Section headings, empty state title |
| `text.headline` | `.headline` | Task name in row |
| `text.subheadline` | `.subheadline` | Secondary info in row |
| `text.caption` | `.caption` | Validation error messages |

## Usage in Swift

Design tokens are applied through the `DesignSystem` enum and the semantic
`Color` extensions defined in `Repeto/Utilities/DesignSystem.swift`:

```swift
// Spacing
.padding(DesignSystem.spacing(.md))            // 16pt
VStack(spacing: DesignSystem.spacing(.lg)) { } // 20pt

// Status / semantic colors
.foregroundStyle(DesignSystem.statusColor(.overdue))
.foregroundStyle(.accent)                       // AccentColor asset
.foregroundStyle(.destructive)

// Icon size
.font(.system(size: DesignSystem.iconSize(.lg)))

// Corner radius
.cornerRadius(DesignSystem.radius(.md))         // 12pt
```

> **Note**: When adding new tokens, update both this file and the Swift
> implementation simultaneously.
>
> **Enforcement**: `.swiftlint.yml` `custom_rules` flag hardcoded frame sizes and
> raw color literals in views, so token usage is checked in CI, not just by convention.
