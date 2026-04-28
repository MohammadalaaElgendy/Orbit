---
name: Modern Productivity UI
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#464555'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#777587'
  outline-variant: '#c7c4d8'
  surface-tint: '#4d44e3'
  primary: '#3525cd'
  on-primary: '#ffffff'
  primary-container: '#4f46e5'
  on-primary-container: '#dad7ff'
  inverse-primary: '#c3c0ff'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#7e3000'
  on-tertiary: '#ffffff'
  tertiary-container: '#a44100'
  on-tertiary-container: '#ffd2be'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#0f0069'
  on-primary-fixed-variant: '#3323cc'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#ffdbcc'
  tertiary-fixed-dim: '#ffb695'
  on-tertiary-fixed: '#351000'
  on-tertiary-fixed-variant: '#7b2f00'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  h1:
    fontFamily: manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  h2:
    fontFamily: manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
    letterSpacing: -0.01em
  h3:
    fontFamily: manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.4'
    letterSpacing: -0.01em
  body-lg:
    fontFamily: inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
    letterSpacing: '0'
  body-md:
    fontFamily: inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
    letterSpacing: '0'
  label-sm:
    fontFamily: inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1'
    letterSpacing: 0.02em
  button:
    fontFamily: inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: '0'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  container-margin: 32px
  gutter: 20px
---

## Brand & Style

This design system is engineered for high-focus environments where clarity and aesthetic precision are paramount. It targets professional users who value efficiency and a "quiet" interface that recedes to prioritize user content. 

The aesthetic is a hybrid of **Minimalism** and **Soft Glassmorphism**. It leverages expansive whitespace and a monochromatic base to reduce cognitive load, while employing translucent layers for modals and persistent headers to maintain spatial context. The emotional response is one of calm, organized authority—feeling premium through subtle details rather than loud visual flourishes.

## Colors

The palette is anchored by a sophisticated **Indigo** primary accent, used sparingly to denote action and focus. 

- **Light Mode:** Uses a "Paper White" foundation with soft Slate-Gray neutrals for secondary information and borders.
- **Dark Mode:** Transitions to deep Charcoal and Navy-Blacks to reduce eye strain, maintaining high legibility through softened white text.
- **Translucency:** Glass surfaces should utilize a 70% opacity of the surface color with a 20px-32px background blur to create a premium sense of depth without sacrificing readability.

## Typography

This system utilizes **Manrope** for headings to provide a refined, modern character, and **Inter** for all body and functional text to ensure maximum utility and legibility. 

The typographic hierarchy relies on tight tracking for large headings and generous line-heights for body copy to facilitate long-form reading. All labels use a slightly heavier weight to remain distinct at smaller sizes.

## Layout & Spacing

The layout follows a **Fluid Grid** model with strict 12-column alignment for desktop views. It uses a 4px baseline shift to ensure all elements are mathematically proportional. 

Sidebars are fixed-width (240px-280px) to provide a stable anchor, while the main content area expands. Use "Safe Zones" of 32px padding around major containers to maintain the minimalistic, airy feel.

## Elevation & Depth

Hierarchy is established through **Ambient Shadows** and **Glassmorphism** rather than heavy borders.

1.  **Level 0 (Base):** Flat background color.
2.  **Level 1 (Cards):** Subtle 1px border (color-mode dependent) with a very soft, 10% opacity shadow (Y: 4, Blur: 12).
3.  **Level 2 (Modals/Overlays):** Glassmorphic surfaces with a 20% white/black border and a deep, diffused shadow (Y: 20, Blur: 40, Spread: -10).
4.  **Blur:** All glass surfaces must apply a `backdrop-filter: blur(20px)` to ensure the content underneath doesn't distract from the primary interaction.

## Shapes

The design system leans into high-radius geometry to feel approachable and contemporary. 

- **Standard Elements:** Buttons and small inputs use a 12px-16px radius.
- **Large Elements:** Cards and main content containers utilize 20px-24px.
- **Overlays:** Modals and dialogs are most aggressive with a 28px radius to signify their "floating" status above the UI.

## Components

- **Buttons:** Primary buttons use a solid Indigo fill with white text. Secondary buttons are ghost-styled with a subtle border. All buttons feature a 0.2s ease-in-out transition on hover.
- **Cards:** Use a white or deep charcoal fill with a 1px stroke. Content inside cards should follow the 16px or 24px padding rule.
- **Dialogs:** Centered, glassmorphic containers with large radii. The background dimming should be a soft 40% neutral tint.
- **Inputs:** Minimalist fields with a focus state that highlights the border in the primary Indigo and adds a soft glow/shadow.
- **Sidebars:** Persistent, slightly darker (dark mode) or lighter (light mode) than the main canvas. Use "Active" states with a vertical pill-shaped indicator next to the menu text.
- **Chips/Badges:** Pill-shaped with low-saturation background colors and high-saturation text for status indicators (e.g., "In Progress," "Done").