---
name: Premium Dark Productivity
colors:
  surface: '#131315'
  surface-dim: '#131315'
  surface-bright: '#39393b'
  surface-container-lowest: '#0e0e10'
  surface-container-low: '#1c1b1d'
  surface-container: '#201f22'
  surface-container-high: '#2a2a2c'
  surface-container-highest: '#353437'
  on-surface: '#e5e1e4'
  on-surface-variant: '#c6c5d5'
  inverse-surface: '#e5e1e4'
  inverse-on-surface: '#313032'
  outline: '#908f9e'
  outline-variant: '#454653'
  surface-tint: '#bdc2ff'
  primary: '#bdc2ff'
  on-primary: '#131e8c'
  primary-container: '#818cf8'
  on-primary-container: '#101b8a'
  inverse-primary: '#4953bc'
  secondary: '#ccbeff'
  on-secondary: '#332664'
  secondary-container: '#4a3d7c'
  on-secondary-container: '#baabf3'
  tertiary: '#f7bd3e'
  on-tertiary: '#402d00'
  tertiary-container: '#c08d00'
  on-tertiary-container: '#3e2b00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e0e0ff'
  primary-fixed-dim: '#bdc2ff'
  on-primary-fixed: '#000767'
  on-primary-fixed-variant: '#2f3aa3'
  secondary-fixed: '#e7deff'
  secondary-fixed-dim: '#ccbeff'
  on-secondary-fixed: '#1e0e4e'
  on-secondary-fixed-variant: '#4a3d7c'
  tertiary-fixed: '#ffdea3'
  tertiary-fixed-dim: '#f7bd3e'
  on-tertiary-fixed: '#261900'
  on-tertiary-fixed-variant: '#5d4200'
  background: '#131315'
  on-background: '#e5e1e4'
  surface-variant: '#353437'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: '800'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
    letterSpacing: -0.01em
  body-base:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
    letterSpacing: '0'
  label-sm:
    fontFamily: Manrope
    fontSize: 13px
    fontWeight: '500'
    lineHeight: '1'
    letterSpacing: 0.02em
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
  xl: 40px
  container-margin: 32px
  gutter: 20px
---

## Brand & Style

The design system is engineered for high-focus professional environments where aesthetic depth and cognitive clarity are paramount. It targets power users who value a sophisticated, "Studio" feel over traditional corporate density. 

The style is a fusion of **Minimalism** and **Glassmorphism**. It relies on high-quality negative space and a disciplined color palette to reduce eye strain during long working sessions. By utilizing layered translucency and light-catching borders, the UI feels tactile and physical despite its digital nature, evoking the sensation of premium hardware.

## Colors

This design system utilizes a "Deep Night" palette. The foundation is built on **Zinc-950 (#09090b)**, providing a true-black base that allows glass elements to pop. 

**Indigo-400 (#818cf8)** serves as the primary action color, used sparingly for focus states and critical CTA buttons to maintain a calm atmosphere. Surfaces are constructed using semi-transparent Zinc-900 shades with varying opacities to create the glass effect. Text colors are strictly tiered: **Zinc-50** for primary content, **Zinc-400** for secondary details, and **Zinc-600** for disabled or tertiary metadata.

## Typography

The design system exclusively uses **Manrope** to achieve a balanced, modern, and highly legible interface. The type scale is designed with a strong vertical rhythm, favoring slightly tighter letter spacing for headlines to create a "locked-in" editorial look. 

Body text utilizes a generous 1.6 line height to ensure readability within complex productivity dashboards. Labels and data points use medium weights with increased letter spacing to distinguish them from prose.

## Layout & Spacing

The layout is built on a **4px baseline grid** with a 12-column fluid system for main content areas. It prioritizes "breathable density"—information is grouped tightly within components, but components themselves are separated by large 24px or 40px gaps. 

Sidebars and utility panels should use fixed widths (e.g., 280px) to provide a stable anchor for the eye, while the main workspace remains fluid to accommodate various window sizes.

## Elevation & Depth

Depth in this design system is achieved through **Tonal Stacking** and **Backdrop Blurs**. Shadows are secondary; the primary depth cue is the "Inner Glow" border highlight.

1.  **Level 0 (Base):** Solid #09090b.
2.  **Level 1 (Cards):** Background blur (20px) with a 60% opacity Zinc-900 fill. Borders are 1px solid `rgba(255, 255, 255, 0.05)`.
3.  **Level 2 (Popovers/Modals):** Background blur (40px) with a 80% opacity Zinc-900 fill. Borders include a top-weighted highlight of `rgba(255, 255, 255, 0.12)` to simulate light hitting the edge.
4.  **Interactive States:** Elements slightly increase in opacity or add a subtle Indigo outer glow (blur 15px, 0.2 opacity) when active.

## Shapes

The shape language is defined by large, sweeping radii that soften the technical nature of the UI. Main application containers and large cards use a **28px corner radius**. 

Standard components like buttons and input fields utilize a **16px radius**. For nested elements (e.g., a chip inside a card), the radius should be reduced to **12px** to maintain visual concentricity. This "hyper-rounded" approach creates the premium, approachable feel essential to the design system's identity.

## Components

-   **Buttons:** Primary actions use a solid Indigo-400 background with Zinc-950 text. Secondary buttons use the glass style with a subtle white border. All buttons have a minimum height of 44px for a tactile, premium feel.
-   **Cards:** Every card must feature `backdrop-filter: blur(20px)` and a thin 1px border highlight. High-priority cards may include a very subtle radial gradient in the top-left corner to simulate a light source.
-   **Inputs:** Fields are dark and recessed (rgba(0,0,0,0.2)) with a 1px border that brightens to Indigo-400 on focus. Text should be Zinc-50.
-   **Chips/Tags:** Small, pill-shaped elements with a Zinc-800 background and Zinc-300 text. No borders.
-   **Lists:** Items are separated by subtle 1px Zinc-800 lines. Hover states should use a soft 5% white overlay rather than a color change.
-   **Checkboxes/Radios:** When checked, these elements glow with the Indigo-400 accent color, utilizing a small drop shadow of the same color to simulate an LED "on" state.