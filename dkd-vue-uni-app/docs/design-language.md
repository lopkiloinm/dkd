# DKD Mobile Design Language

This is the baseline visual system for the Vue uni-app client. It is extracted from the strongest existing patterns in the codebase and intentionally removes the current mix of circles, pills, glass cards, and one-off icon treatments.

## Visual Direction

The app should feel like a modern operations product:

- Dark neutral canvas with depth, not pure black
- Soft rectangular geometry as the default shape language
- Tonal accents instead of loud solid fills
- Glass used sparingly for floating chrome and overlays only
- Clear hierarchy through spacing, contrast, and elevation rather than decoration

## Geometry Rules

- Use rounded rectangles for almost everything interactive.
- Default control radius: `14px`
- Default panel radius: `20px`
- Use pills only for chips, segmented filters, badges, and tab selectors.
- Use circles only for avatars, status dots, loading indicators, and close affordances.

That means:

- Quick actions use rounded-square icon tiles, not circles.
- Cards use panel radii, not pills.
- Filter chips and badges can be pill-shaped.

## Color System

Shared tokens live in [src/styles/_variables.scss](/Users/martinliu/Documents/GitHub/dkd/dkd-vue-uni-app/src/styles/_variables.scss).

- Primary: electric blue for navigation emphasis and key actions
- Secondary: teal for collaborative or network/system actions
- Success: green
- Warning: amber
- Error: red
- Surface stack: `bg-primary`, `bg-secondary`, `bg-tertiary`, `bg-elevated`

Rules:

- Reserve solid primary fills for the highest-emphasis CTA only.
- Prefer tonal fills such as `rgba(primary, 0.14)` for icon tiles, badges, and lightweight states.
- Avoid introducing page-specific gradients unless they represent rank, data, or a true brand moment.

## Surface System

Shared surface rules live in [src/styles/_mixins.scss](/Users/martinliu/Documents/GitHub/dkd/dkd-vue-uni-app/src/styles/_mixins.scss) and [src/styles/_design-language.scss](/Users/martinliu/Documents/GitHub/dkd/dkd-vue-uni-app/src/styles/_design-language.scss).

- `surface-panel`: default card, module, and content container
- `surface-muted`: secondary container for quick actions and compact controls
- `surface-floating`: overlays, floating app bars, drawers, sheets

Rules:

- Use borders plus subtle elevation together. Do not rely on shadow alone.
- Glass belongs on floating navigation, search, modals, and sheets, not on every list row.
- Prefer one surface treatment per screen section. Mixing three surface styles in one block should be considered a smell.

## Icon Treatment

The standard icon container is a 44x44 rounded rectangle.

- Use `.icon-tile`
- Pair it with one tone modifier:
- `.icon-tile--primary`
- `.icon-tile--secondary`
- `.icon-tile--success`
- `.icon-tile--warning`
- `.icon-tile--error`
- `.icon-tile--neutral`

Rules:

- Quick actions and stat icons use tonal tiles.
- Do not switch between solid circles, translucent pills, and plain glyphs inside the same screen.
- If an icon does not need a container, keep it containerless everywhere in that pattern.

## Component Standards

- `Card`: default content container
- `Button`: solid primary for the main action, secondary or ghost for supporting actions
- `Badge`: pill only
- `Chip` and segmented filters: pill only
- `BottomNav`: floating pill container
- `AppBar`: flat or floating glass, never both on the same screen

## Page Composition

- Keep section spacing on the 16/24/32 scale.
- A screen should usually have one dominant accent color and semantic colors only where meaning requires them.
- Quick action grids should use the shared `.quick-action-tile` primitive.

## Migration Guidance

When touching an existing screen:

1. Replace custom icon wrappers with `.icon-tile` variants.
2. Replace ad hoc cards with shared `Card` or `.surface-card` treatment.
3. Replace custom filter pills with shared pill tokens.
4. Remove raw hardcoded `rgba(...)`, radius, and shadow values when a token already exists.

## Current Source Of Truth

- Tokens: [src/styles/_variables.scss](/Users/martinliu/Documents/GitHub/dkd/dkd-vue-uni-app/src/styles/_variables.scss)
- Mixins: [src/styles/_mixins.scss](/Users/martinliu/Documents/GitHub/dkd/dkd-vue-uni-app/src/styles/_mixins.scss)
- Global primitives: [src/styles/_design-language.scss](/Users/martinliu/Documents/GitHub/dkd/dkd-vue-uni-app/src/styles/_design-language.scss)
- Shared layout layer: [src/styles/_layout.scss](/Users/martinliu/Documents/GitHub/dkd/dkd-vue-uni-app/src/styles/_layout.scss)
