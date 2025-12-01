# JobMatchNow Color Palette

> **Last Updated:** December 2025  
> **Swift Reference:** `JobMatchNow/Core/ThemeColors.swift`  
> **System:** Palette A – Ink + Indigo Monochromatic System

This document describes the official JobMatchNow brand color palette. Our cool indigo-violet system evokes **trust, clarity, and modern calm** – perfect for a premium AI-powered career assistant.

---

## 🎯 Palette Philosophy

### Why Cool Indigo/Violet?

**Trust & Premium Feel**  
Cool purples and indigos communicate sophistication, intelligence, and trustworthiness. Unlike generic "blue job board" palettes, our deeper tones create a distinctive, premium experience.

**Calm & Focused UX**  
The monochromatic/analogous palette supports a calm, focused user experience. Job seekers are often stressed – our palette provides visual relief while maintaining clarity.

**Accessibility First**  
High contrast between Ink Black text and Paper White surfaces ensures excellent readability. The palette is designed for WCAG AA compliance.

### 60-30-10 Rule

| Proportion | Category | Colors |
|------------|----------|--------|
| **~60%** | Neutral Surfaces | `paperWhite`, `surfaceLight`, `cardLight` |
| **~30%** | Structure Colors | `mistBlue`, `borderGrey`, `softGrey` |
| **~10%** | Brand Accents | `deepIndigo`, `slateViolet` |

---

## 🎨 Core Palette

### `inkBlack` – Ink Black
| Property | Value |
|----------|-------|
| **Hex** | `#000505` |
| **RGB** | 0, 5, 5 |
| **Swift** | `ThemeColors.inkBlack` |

**Usage:**
- Dark mode app background
- Primary text on light backgrounds (via `textOnLight` alias)
- High-contrast anchoring elements
- Dark mode navigation shells

**Design Note:**  
Near-black with a subtle cool undertone. Creates depth without pure black's harshness.

---

### `deepIndigo` – Deep Indigo ⭐
| Property | Value |
|----------|-------|
| **Hex** | `#3B3355` |
| **RGB** | 59, 51, 85 |
| **Swift** | `ThemeColors.deepIndigo` |

**Usage:**
- **Primary CTA buttons** (Upload Résumé, Sign In, Get Matches)
- Key accent elements and highlights
- Active/selected states
- Primary text on light backgrounds (via `textOnLight`)

**Design Note:**  
**This is our hero brand color.** Rich, confident purple-indigo that drives action while communicating trust.

---

### `slateViolet` – Slate Violet
| Property | Value |
|----------|-------|
| **Hex** | `#5D5D81` |
| **RGB** | 93, 93, 129 |
| **Swift** | `ThemeColors.slateViolet` |

**Usage:**
- Secondary CTA buttons
- Tab highlight states
- Selected chips and filters
- Links and interactive text
- Badges and tags

**Design Note:**  
Muted purple-grey that complements Deep Indigo. Provides visual interest for secondary actions without competing with primary CTAs.

---

### `mistBlue` – Mist Blue
| Property | Value |
|----------|-------|
| **Hex** | `#BFCDE0` |
| **RGB** | 191, 205, 224 |
| **Swift** | `ThemeColors.mistBlue` |

**Usage:**
- Soft backgrounds and highlights
- Badge backgrounds
- Illustration fills
- Subtle emphasis areas
- Secondary text on dark backgrounds

**Design Note:**  
Calm, soft blue-grey that creates breathing room. Use at 10-30% opacity for very subtle tints.

---

### `paperWhite` – Paper White
| Property | Value |
|----------|-------|
| **Hex** | `#FEFCFD` |
| **RGB** | 254, 252, 253 |
| **Swift** | `ThemeColors.paperWhite` |

**Usage:**
- Light mode app background
- Card backgrounds
- Modal surfaces
- Text on dark backgrounds

**Design Note:**  
Warm off-white that's softer than pure white (#FFFFFF). Reduces eye strain during extended use.

---

## 🔘 Supporting Neutrals

### `softGrey` – Soft Grey
| Property | Value |
|----------|-------|
| **Hex** | `#6B7280` |
| **RGB** | 107, 114, 128 |
| **Swift** | `ThemeColors.softGrey` |

**Usage:**
- Secondary text on light backgrounds
- Captions and timestamps
- Less prominent metadata
- Placeholder text

---

### `borderGrey` – Border Grey
| Property | Value |
|----------|-------|
| **Hex** | `#D1D5DB` |
| **RGB** | 209, 213, 219 |
| **Swift** | `ThemeColors.borderGrey` |

**Usage:**
- Dividers and separators
- Input field borders
- Card outlines (when needed)
- Table row separators

---

### `surfaceGreyDark` – Surface Grey Dark
| Property | Value |
|----------|-------|
| **Hex** | `#1A1B26` |
| **RGB** | 26, 27, 38 |
| **Swift** | `ThemeColors.surfaceGreyDark` |

**Usage:**
- Dark mode card backgrounds
- Dark mode modals
- Elevated surfaces in dark mode

**Design Note:**  
Slightly lighter than Ink Black to create visual hierarchy in dark mode.

---

## 🔴 Utility / Status Colors

> ⚠️ **Important:** These colors are reserved for status indication ONLY. Never use them as brand colors or primary backgrounds.

### `errorRed` – Error Red
| Property | Value |
|----------|-------|
| **Hex** | `#E74C3C` |
| **RGB** | 231, 76, 60 |
| **Swift** | `ThemeColors.errorRed` |

**Usage:**
- Delete/destructive buttons
- Error messages and banners
- Form validation errors
- Critical alerts

---

### `warningAmber` – Warning Amber
| Property | Value |
|----------|-------|
| **Hex** | `#F39C12` |
| **RGB** | 243, 156, 18 |
| **Swift** | `ThemeColors.warningAmber` |

**Usage:**
- Warning states (non-critical)
- Pending states
- Attention indicators
- Caution badges

---

### `successGreen` – Success Green
| Property | Value |
|----------|-------|
| **Hex** | `#27AE60` |
| **RGB** | 39, 174, 96 |
| **Swift** | `ThemeColors.successGreen` |

**Usage:**
- Success banners
- Completed states
- Positive feedback
- Checkmarks and confirmations

---

### `infoTeal` – Info Teal
| Property | Value |
|----------|-------|
| **Hex** | `#17A2B8` |
| **RGB** | 23, 162, 184 |
| **Swift** | `ThemeColors.infoTeal` |

**Usage:**
- Informational banners
- Tips and hints
- Neutral callouts

---

## 🌈 Gradient System

### Brand Gradient (Hero)
**Colors:** `inkBlack` → `deepIndigo` → `slateViolet` → `mistBlue`  
**Swift:** `ThemeColors.brandGradient`  
**Direction:** Top-left to bottom-right

**Usage:**
- Splash screens
- Onboarding backgrounds
- Marketing hero sections
- App icon background

---

### Dark Gradient
**Colors:** `inkBlack` → `deepIndigo`  
**Swift:** `ThemeColors.darkGradient`  
**Direction:** Top to bottom

**Usage:**
- Dark mode backgrounds
- Navigation bars (dark mode)
- Analyzing/loading screens

---

### Light Gradient
**Colors:** `slateViolet` → `mistBlue`  
**Swift:** `ThemeColors.lightGradient`

**Usage:**
- Card headers (light mode)
- Section backgrounds
- Soft emphasis areas

---

### Accent Gradient
**Colors:** `slateViolet` → `mistBlue`  
**Swift:** `ThemeColors.accentGradient`

**Usage:**
- Special emphasis
- Premium feature highlights
- Promotional elements

---

## 📐 Semantic Token Map

| Token | Maps To | Role |
|-------|---------|------|
| `primaryBrand` | `deepIndigo` | Primary CTAs, key accents |
| `primaryCTA` | `deepIndigo` | Same as primaryBrand |
| `primaryComplement` | `slateViolet` | Secondary CTAs, selections |
| `secondaryCTA` | `slateViolet` | Same as primaryComplement |
| `softComplement` | `mistBlue` | Soft backgrounds, badges |
| `deepComplement` | `inkBlack` | Dark mode cards, shells |
| `midnight` | `inkBlack` | Dark mode backgrounds |
| `surfaceLight` | `paperWhite` | Light mode background |
| `surfaceDark` | `inkBlack` | Dark mode background |
| `cardLight` | `paperWhite` | Cards (light mode) |
| `cardDark` | `surfaceGreyDark` | Cards (dark mode) |
| `textOnLight` | `deepIndigo` | Text on light surfaces |
| `textOnDark` | `paperWhite` | Text on dark surfaces |
| `borderSubtle` | `borderGrey` | Dividers, borders |

---

## 📱 Application Guidelines

### Button Hierarchy

| Level | Background | Text | Border |
|-------|------------|------|--------|
| **Primary CTA** | `deepIndigo` | `paperWhite` | none |
| **Secondary CTA** | `slateViolet` | `paperWhite` | none |
| **Tertiary** | `paperWhite` | `deepIndigo` | `deepIndigo` (1.5px) |
| **Destructive** | `errorRed` | white | none |
| **Ghost/Text** | transparent | `deepIndigo` | none |

**Example:**
```swift
// Primary CTA
Button("Upload Résumé") { }
    .foregroundColor(ThemeColors.textOnDark)
    .background(ThemeColors.primaryCTA)
    .cornerRadius(12)

// Secondary CTA
Button("Learn More") { }
    .foregroundColor(ThemeColors.textOnDark)
    .background(ThemeColors.secondaryCTA)
    .cornerRadius(12)

// Tertiary
Button("Cancel") { }
    .foregroundColor(ThemeColors.deepIndigo)
    .background(ThemeColors.cardLight)
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(ThemeColors.deepIndigo, lineWidth: 1.5)
    )
```

---

### Text Hierarchy

| Context | Color | Notes |
|---------|-------|-------|
| **Headline (light)** | `textOnLight` | Deep Indigo |
| **Body (light)** | `textOnLight` | Deep Indigo |
| **Secondary (light)** | `textSecondaryLight` | Soft Grey |
| **Caption (light)** | `textOnLight` at 60% | Reduced opacity |
| **Headline (dark)** | `textOnDark` | Paper White |
| **Body (dark)** | `textOnDark` | Paper White |
| **Secondary (dark)** | `textSecondaryDark` | Mist Blue |

---

### Navigation & Tab Bars

**Light Mode:**
| Element | Color |
|---------|-------|
| Nav background | `surfaceLight` |
| Title text | `textOnLight` |
| Active tab icon | `deepIndigo` |
| Inactive tab icon | `slateViolet` at 50% |

**Dark Mode:**
| Element | Color |
|---------|-------|
| Nav background | `surfaceDark` |
| Title text | `textOnDark` |
| Active tab icon | `mistBlue` |
| Inactive tab icon | `mistBlue` at 50% |

---

### Cards & Containers

**Light Mode:**
| Element | Color |
|---------|-------|
| Background | `cardLight` |
| Border | `borderGrey` (optional) |
| Shadow | Subtle grey shadow |

**Dark Mode:**
| Element | Color |
|---------|-------|
| Background | `cardDark` |
| Border | none (rely on elevation) |
| Shadow | none |

---

### Badges & Pills

| Type | Background | Text |
|------|------------|------|
| **Primary** | `deepIndigo` | `paperWhite` |
| **Secondary** | `slateViolet` | `paperWhite` |
| **Soft** | `mistBlue` | `deepIndigo` |
| **Success** | `successGreen` | white |
| **Warning** | `warningAmber` | `inkBlack` |
| **Error** | `errorRed` | white |
| **Neutral** | `borderGrey` | `textOnLight` |

---

## ✅ Accessibility & Testing

### Required Contrast Checks

Run contrast checks for these primary pairs (target WCAG AA 4.5:1):

| Foreground | Background | Expected |
|------------|------------|----------|
| `textOnLight` (deepIndigo) | `surfaceLight` (paperWhite) | ✅ Pass |
| `textOnDark` (paperWhite) | `surfaceDark` (inkBlack) | ✅ Pass |
| `paperWhite` | `deepIndigo` | ✅ Pass |
| `paperWhite` | `slateViolet` | ✅ Pass |

### Accessibility Guidelines

1. **Never rely on color alone** – Always pair colors with icons, labels, or patterns
2. **Avoid long text on saturated backgrounds** – Gradients and brand colors are for heroes, not body text
3. **Test in both light and dark mode** – Ensure all states are readable
4. **Consider color blindness** – Our purple/blue palette works well for most forms of color blindness

---

## 🔧 Implementation Notes

### Golden Rules

1. **All SwiftUI views MUST use `ThemeColors` tokens** – Never hard-code hex values
2. **Use semantic tokens when possible** – `primaryBrand` instead of `deepIndigo` for future-proofing
3. **Gradients are for heroes only** – Splash, onboarding, marketing sections – NOT behind body text
4. **Status colors are reserved** – Red=error, Amber=warning, Green=success – Don't repurpose

### Dark Mode Strategy

The app uses `darkGradient` (Ink → Indigo) for dark mode backgrounds, creating a unified, branded dark experience rather than generic system dark colors.

### Legacy Compatibility

The `ThemeColors` file includes legacy aliases for the previous green palette:
- `wealthDark` → `inkBlack`
- `wealthDeep` → `surfaceGreyDark`
- `wealthStrong` → `deepIndigo`
- `wealthBright` → `slateViolet`
- `wealthLight` → `mistBlue`
- `accentPurple` → `slateViolet`

These allow gradual migration. New code should use the canonical Palette A names.

---

## 🎯 Component Quick Reference

| Screen | Background | Primary CTA | Text |
|--------|------------|-------------|------|
| **Splash** | `darkGradient` | n/a | `textOnDark` |
| **Onboarding** | `darkGradient` | `primaryBrand` | `textOnDark` |
| **Auth** | `surfaceDark` | `primaryBrand` | `textOnDark` |
| **Upload** | `surfaceLight` | `primaryBrand` | `textOnLight` |
| **Analyzing** | `darkGradient` | n/a | `textOnDark` |
| **Results** | `surfaceLight` | `primaryBrand` | `textOnLight` |
| **Dashboard** | `surfaceLight` | `primaryBrand` | `textOnLight` |
| **Settings** | System List | `primaryBrand` | System |

---

*Questions? Reference `Core/ThemeColors.swift` or contact the design team.*
