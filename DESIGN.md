---
status: reconciled
updated: 2026-11-05
product: LuceneX Warehouse Operations
colors:
  ink: '#181715'
  ink-soft: '#6F6A63'
  paper: '#F5F3EF'
  panel: '#FFFFFF'
  line: '#DED9D1'
  accent: '#C65A2E'
  accent-soft: '#F4DED3'
  accent-light: '#DF825D'
typography:
  display: 'Inter, Helvetica Neue, Arial, sans-serif'
  body: 'Inter, Helvetica Neue, Arial, sans-serif'
  mono: 'ui-monospace, SFMono-Regular, Menlo, monospace'
rounded:
  control: 10px
  surface: 14px
spacing:
  page-gutter: 'clamp(24px, 5vw, 80px)'
  section: 'clamp(48px, 8vh, 112px)'
components:
  primary-button: 'accent fill, white label, 10px radius'
  secondary-button: 'paper fill, ink label, 1px line'
  input: 'white fill, line border, 10px radius'
---

# LuceneX Warehouse Operations — visual design contract

This document is the source of truth for the frontend refactor. It describes how the product should look; behavioral rules live in [EXPERIENCE.md](./EXPERIENCE.md). If an existing screen conflicts with this document, the refactor should follow this contract.

The reconciliation pass also covers the visual warehouse overlays and analytics: visible labels must come from the English/Latvian locale packs, and sample spatial data must not introduce Chinese labels into charts or detail panels.

## Brand & Style

LuceneX should feel like a precise operations partner: calm, direct, practical, and technically confident. The interface should make the next warehouse action obvious without looking like a generic admin template.

Use a high-contrast editorial foundation: charcoal ink, warm off-white paper, white working surfaces, thin warm-gray rules, and one dark-orange accent. Orange is an action and attention color, not decoration.

The visual language should suggest route planning, signal, movement, and physical space through restrained lines, grids, progress indicators, and directional geometry. Prefer CSS geometry or purpose-built LuceneX assets over stock imagery.

## Colors

| Token | Value | Use |
|---|---|---|
| `{colors.ink}` | `#181715` | Primary text, dark navigation, hero surfaces |
| `{colors.ink-soft}` | `#6F6A63` | Secondary text, helper copy |
| `{colors.paper}` | `#F5F3EF` | App background |
| `{colors.panel}` | `#FFFFFF` | Forms, tables, dialogs, working surfaces |
| `{colors.line}` | `#DED9D1` | Dividers, borders, table rules |
| `{colors.accent}` | `#C65A2E` | Primary actions, active navigation, alerts, focus emphasis |
| `{colors.accent-soft}` | `#F4DED3` | Selected states, soft badges, avatar surfaces |
| `{colors.accent-light}` | `#DF825D` | Dark-surface accent text and secondary signal |

Rules:

- Use one accent family only: dark orange. Do not reintroduce purple, green, blue, or arbitrary status colors.
- Error states may use a dedicated accessible red only when the meaning is genuinely destructive or invalid.
- Never use the accent as a large decorative gradient or glow.
- Text on `{colors.accent}` is white; text on `{colors.accent-soft}` is `{colors.ink}`.

## Typography

- Use a strong sans-serif throughout. Do not mix in a decorative serif.
- Display headings are heavy, tightly tracked, and left-aligned. Typical scale: `clamp(2.8rem, 6vw, 6.8rem)` with line-height `.94`.
- Product headings should be concise: one clear idea, generally no more than two lines on desktop.
- Body copy uses `{colors.ink-soft}`, 1.0–1.05rem, line-height 1.55–1.7.
- Eyebrows use uppercase, 0.68–0.72rem, weight 800, letter spacing `.16em`.
- Preserve Latvian diacritics. Never force English labels into Latvian screens.

## Layout & Spacing

- Desktop shell: fixed left navigation around 272px, flexible content area, 72px header.
- Main content uses generous page gutters and a warm paper background.
- Prefer asymmetric, left-anchored layouts over centered dashboard stacks.
- Use grid for repeated operational information; use whitespace and rules before adding cards.
- Keep primary actions visible and on one line.
- Login is a split layout: dark brand panel on the left, white authentication panel on the right. On small screens, use the authentication panel alone.
- The public licenses page is a simple editorial document, not an authenticated app screen.

## Elevation & Depth

- Default separation is a 1px `{colors.line}` rule.
- Use soft, warm-tinted shadows only for floating forms, menus, and primary action feedback.
- Avoid stacked glass cards, black shadows, and decorative blur.
- Dark surfaces may use a very restrained orange radial field to establish focus, never a generic mesh gradient.

## Shapes

- Surface radius: `{rounded.surface}`.
- Form controls and buttons: `{rounded.control}`.
- Avoid mixing pill controls, sharp cards, and unrelated corner systems.
- Status dots may be circular; this does not change the global surface radius.

## Components

### Logo and icon

Use the LuceneX three-bar mark and LuceneX wordmark. The mark must pass contrast on both light and dark surfaces. Use `/lucenex.svg` for the browser icon; do not use `webLogoMini.png`, `favicon.ico`, or stock product imagery.

### Navigation

The active item is a solid `{colors.accent}` block with white text. Inactive items are ink-soft on paper, with a warm-gray hover surface. Icons use one consistent MDI family and should communicate the operation, not decoration.

### Buttons

Primary: `{colors.accent}` fill, white label, 10px radius, subtle orange-tinted shadow, tactile 1px upward hover movement.

Secondary: white or paper fill, ink label, `{colors.line}` border.

Destructive: reserved for irreversible actions and paired with explicit confirmation.

### Forms

Labels sit above fields. Inputs are white, bordered, and clearly focused. Never use placeholder text as the only label. Validation text appears directly below the field.

### Data surfaces

Tables and operational lists use white surfaces, clear column labels, thin rules, readable density, and orange only for the active row/action. Avoid turning every row into a card.

### Operational graphics

Use original CSS/SVG geometry for route maps, warehouse grids, progress signals, and spatial context. Do not add stock photography or stock warehouse illustrations.

## Do's and Don'ts

Do:

- Make the next action visually obvious.
- Use short operational copy: assess, receive, move, pick, pack, ship, measure.
- Keep the brand visible on dark surfaces with a light wordmark.
- Design loading, empty, error, and permission states as first-class screens.

Don't:

- Reintroduce ModernWMS branding in visible UI copy.
- Use purple as a fallback Vuetify primary color.
- Add generic dashboard cards or stock imagery to fill empty space.
- Hide a failed API request behind a vague toast when inline context is possible.
- Treat the login screen as the only branded surface; the app shell must carry the system too.
