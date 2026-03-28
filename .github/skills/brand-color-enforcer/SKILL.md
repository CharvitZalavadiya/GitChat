---
name: brand-color-enforcer
description: "Use when creating or editing UI to enforce brand colors, palette tokens, theme variables, and prevent off-brand color usage in CSS, Tailwind, and component styles. Trigger phrases: brand color enforcer, use brand colors, enforce palette, keep colors on brand."
---

# Brand Color Enforcer

## Purpose
Ensure every UI change stays on brand by using only approved brand colors and semantic color tokens.

## Approved Brand Palette
Use this exact base palette unless the user explicitly requests a change:
- Primary (teal): `#0f766e`
- Secondary (purple): `#7e22ce`
- Tertiary (yellow): `#eab308`

Required shade variables for each brand color:
- `-lighter`
- `-light`
- base (no suffix)
- `-dark`
- `-darker`

Required variable names:
- `--primary`, `--primary-light`, `--primary-lighter`, `--primary-dark`, `--primary-darker`
- `--secondary`, `--secondary-light`, `--secondary-lighter`, `--secondary-dark`, `--secondary-darker`
- `--tertiary`, `--tertiary-light`, `--tertiary-lighter`, `--tertiary-dark`, `--tertiary-darker`

## Required Semantic Status Colors
These are required and must come from the root variables in `apps/client/app/globals.css`:
- Success: `--success`, `--success-light`, `--success-dark`
- Warning: `--warning`, `--warning-light`, `--warning-dark`
- Error: `--error`, `--error-light`, `--error-dark`
- Info: `--info`, `--info-light`, `--info-dark`

## Source Of Truth
All color tokens in this repository must reference `apps/client/app/globals.css`.
If a color does not exist there, add it there first, then consume it via semantic tokens.

## Inputs
You should gather these before styling work starts:
- Primary brand color(s) (hex/rgb/hsl)
- Secondary/supporting brand color(s)
- Neutral scale (background/text/border)
- Semantic mappings (success/warning/error/info)
- Accessibility targets (for example WCAG AA)

If a required color input is missing, ask for it before continuing with final color choices.

## Rules
1. Never introduce raw ad-hoc color values in new code when a brand token can be used.
2. Prefer semantic tokens first (for example `--color-primary`, `--color-surface`, `--color-text`).
3. Keep state colors consistent: hover/focus/active/disabled must come from approved palette ramps.
4. Preserve contrast and readability; if a brand color fails contrast, propose the nearest approved alternative.
5. Avoid mixing unrelated palettes across components.
6. When editing existing code, replace hard-coded colors with approved tokens where safe.
7. In this repository, always map UI colors through the root variables listed in `apps/client/app/globals.css`.
8. Do not rename or replace `primary` teal, `secondary` purple, or `tertiary` yellow without explicit user approval.
9. Always use `success`, `warning`, `error`, and `info` variables from `apps/client/app/globals.css` for status UI.

## Enforcement Workflow
1. Detect existing theme system (CSS variables, Tailwind theme, design tokens, or component constants).
2. Build or confirm a brand token map.
3. Apply only token-based colors in all new and updated UI code.
4. Audit touched files for off-brand literals (hex, rgb, hsl, named colors) and normalize them.
5. Summarize what tokens were used and any exceptions.

## Token Template
Use or adapt this token set:

```css
:root {
  --primary: #0f766e;
  --primary-light: #14b8a6;
  --primary-lighter: #99f6e4;
  --primary-dark: #115e59;
  --primary-darker: #134e4a;

  --secondary: #7e22ce;
  --secondary-light: #a855f7;
  --secondary-lighter: #e9d5ff;
  --secondary-dark: #6b21a8;
  --secondary-darker: #581c87;

  --tertiary: #eab308;
  --tertiary-light: #facc15;
  --tertiary-lighter: #fef08a;
  --tertiary-dark: #ca8a04;
  --tertiary-darker: #a16207;

  --success: #16a34a;
  --success-light: #4ade80;
  --success-dark: #15803d;

  --warning: #d97706;
  --warning-light: #fbbf24;
  --warning-dark: #b45309;

  --error: #dc2626;
  --error-light: #f87171;
  --error-dark: #b91c1c;

  --info: #2563eb;
  --info-light: #60a5fa;
  --info-dark: #1d4ed8;
}
```

## Tailwind Guidance
- Map brand tokens into Tailwind theme colors.
- Use utility classes backed by tokens, not one-off bracketed literals.
- Avoid repeated classes like `text-[#xxxxxx]` and `bg-[#xxxxxx]` unless explicitly approved.

## Exception Policy
If a request requires a non-brand color (campaign, partner co-branding, data visualization), do this:
1. Call out the exception clearly.
2. Limit it to the smallest scope.
3. Keep base UI chrome on brand.

## Completion Checklist
- Brand tokens exist and are used.
- No unintended off-brand literals were introduced in changed files.
- Interactive states use approved ramps.
- Contrast remains acceptable for text and controls.
