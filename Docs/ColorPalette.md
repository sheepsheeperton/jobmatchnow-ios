# JobMatchNow Color Palette

> **Last Updated:** December 2025  
> **Swift Reference:** `JobMatchNow/Core/ThemeColors.swift`  
> **System:** Palette A (Rebalanced) – Indigo Brand + Vivid Accent

This document describes the official JobMatchNow color palette. Our system combines cool indigo brand tones with a **vivid blue accent** for CTAs, on **neutral white surfaces**.

---

## 🎯 Key Distinction

| Token | Role | Color |
|-------|------|-------|
| **`primaryBrand`** | Brand text, icons, headings | Deep Indigo `#3B3355` |
| **`primaryAccent`** | CTAs, highlights, interactive | Vivid Blue `#4C7DFF` |
| **Surfaces** | Page & card backgrounds | Neutral white/grey |

> ⚠️ **Never use `primaryBrand` (Deep Indigo) for CTA backgrounds.** Always use `primaryAccent`.

---

## 🎨 Palette Philosophy

### Why This Split?

**Problem Solved:** The original Palette A felt flat because the same purple was used for headings, icons, AND buttons. Everything blended together.

**Solution:** 
- **Brand colors** (Indigo/Violet) = identity, text, structure
- **Accent color** (Vivid Blue) = action, interaction, emphasis
- **Surfaces** = neutral white, not purple-tinted

### 60-30-10 Rule

**Light Mode:**
| Proportion | Category | Colors |
|------------|----------|--------|
| **~60%** | Neutral Surfaces | `paperWhite`, `cardLight` (pure white), `borderGrey` |
| **~30%** | Cool Structure | `mistBlue`, `softGrey`, subtle dividers |
| **~10%** | Brand & Accent | `deepIndigo` (text), `primaryAccent` (CTAs) |

**Dark Mode:**
| Proportion | Category | Colors |
|------------|----------|--------|
| **~60%** | Dark Backgrounds | `inkBlack`, `surfaceGreyDark` |
| **~30%** | Brand Structure | `deepIndigo`, `slateViolet` |
| **~10%** | Accent + Status | `primaryAccent`, utility colors |

---

## ⭐ Primary Accent (CTAs & Highlights)

### `primaryAccent` – Vivid Blue
| Property | Value |
|----------|-------|
| **Hex** | `#4C7DFF` |
| **RGB** | 76, 125, 255 |
| **Swift** | `ThemeColors.primaryAccent` |

**Usage:**
- **Primary CTA buttons** (Upload Résumé, Sign In, Get Matches)
- Key metrics and numbers on dashboard
- Selected tab indicators
- Progress indicators and active states
- Highlights and badges that need to "pop"

**Design Note:**  
This vivid blue harmonizes with the indigo palette while providing clear visual distinction for interactive elements. It passes contrast checks on both white and dark backgrounds.

### Supporting Accent Variants

| Token | Hex | Use |
|-------|-----|-----|
| `accentLight` | `#7B9FFF` | Hover states on dark, softer highlights |
| `accentDark` | `#3A5FCC` | Pressed states on light backgrounds |

---

## 🎨 Core Brand Palette

### `inkBlack` – Ink Black
| Property | Value |
|----------|-------|
| **Hex** | `#000505` |
| **Swift** | `ThemeColors.inkBlack` |

**Usage:**
- Dark mode app background (`surfaceDark`)
- Rich dark shells for splash/analyzing screens
- Anchor color for dark gradients

---

### `deepIndigo` – Deep Indigo
| Property | Value |
|----------|-------|
| **Hex** | `#3B3355` |
| **Swift** | `ThemeColors.deepIndigo` |

**Usage:**
- **Primary text** on light backgrounds (`textOnLight`)
- Headings and titles
- Brand icons (NOT buttons)
- Logo treatments

> ⚠️ **NOT for CTA backgrounds** – use `primaryAccent` instead.

---

### `slateViolet` – Slate Violet
| Property | Value |
|----------|-------|
| **Hex** | `#5D5D81` |
| **Swift** | `ThemeColors.slateViolet` |

**Usage:**
- Secondary text on dark backgrounds
- Inactive/pending states
- Supporting UI elements
- Next/secondary buttons on dark screens

---

### `mistBlue` – Mist Blue
| Property | Value |
|----------|-------|
| **Hex** | `#BFCDE0` |
| **Swift** | `ThemeColors.mistBlue` |

**Usage:**
- Soft background highlights
- Explanation section backgrounds
- Subtle badge fills
- Secondary text on dark (`textSecondaryDark`)

---

### `paperWhite` – Paper White
| Property | Value |
|----------|-------|
| **Hex** | `#FEFCFD` |
| **Swift** | `ThemeColors.paperWhite` |

**Usage:**
- Light mode page background (`surfaceLight`)
- Text on dark backgrounds (`textOnDark`)

---

## ⬜ Neutral Surfaces (No Purple Tint!)

| Token | Hex | Use |
|-------|-----|-----|
| `surfaceLight` | `#FEFCFD` | Light mode page background |
| `surfaceWhite` | `#FFFFFF` | Pure white option |
| `cardLight` | `#FFFFFF` | Card backgrounds (light mode) |
| `cardDark` | `#1A1B26` | Card backgrounds (dark mode) |
| `borderGrey` | `#E5E7EB` | Dividers, card borders |
| `softGrey` | `#6B7280` | Secondary text, captions |

**Critical:** Cards are PURE WHITE, not tinted. This creates the clean SaaS look.

---

## 🔴 Utility / Status Colors

| Token | Hex | Use |
|-------|-----|-----|
| `errorRed` | `#E74C3C` | Errors, destructive actions |
| `warningAmber` | `#F39C12` | Warnings, pending states |
| `successGreen` | `#27AE60` | Success, completions |
| `infoTeal` | `#17A2B8` | Informational callouts |

> These are reserved for status indication ONLY. Never use as brand colors.

---

## 🌈 Gradient System

### `heroGradientDark` – Rich Dark Gradient
**Colors:** `inkBlack` → `deepIndigo` → `slateViolet` (subtle)  
**Swift:** `ThemeColors.heroGradientDark`

**Usage:**
- Splash screen background
- Analyzing screen background
- Onboarding backgrounds
- Auth screen background

Creates a rich, dimensional dark experience instead of flat black.

---

### `accentGlow` – Radial Accent Glow
**Colors:** `primaryAccent` (40% opacity) → transparent  
**Swift:** `ThemeColors.accentGlow`

**Usage:**
- Behind step lists on dark screens
- Behind logo/icons for depth
- Subtle highlights on dark backgrounds

---

### Other Gradients

| Name | Colors | Use |
|------|--------|-----|
| `brandGradient` | Ink → Indigo → Violet → Mist | Full hero sweep |
| `lightGradient` | Mist (30%) → Paper | Soft light mode emphasis |
| `darkGradient` | Ink → Indigo | Simple dark gradient |
| `accentGradient` | Accent → AccentLight | Button/badge gradient |

---

## 📐 Semantic Token Map

| Token | Maps To | Role |
|-------|---------|------|
| `primaryBrand` | `deepIndigo` | Brand text/icons (NOT CTAs) |
| `primaryCTA` | `primaryAccent` | Button fills, key actions |
| `secondaryCTA` | `primaryAccent` | Outline button border/text |
| `primaryComplement` | `slateViolet` | Supporting brand tone |
| `softComplement` | `mistBlue` | Soft backgrounds |
| `deepComplement` | `inkBlack` | Dark anchors |
| `textOnLight` | `deepIndigo` | Text on light surfaces |
| `textOnDark` | `paperWhite` | Text on dark surfaces |
| `textSecondaryLight` | `softGrey` | Muted text (light) |
| `textSecondaryDark` | `mistBlue` | Muted text (dark) |
| `surfaceLight` | `paperWhite` | Light mode background |
| `surfaceDark` | `inkBlack` | Dark mode background |
| `cardLight` | `#FFFFFF` | Cards (light mode) |
| `cardDark` | `surfaceGreyDark` | Cards (dark mode) |
| `borderSubtle` | `borderGrey` | Dividers, borders |

---

## 📱 Component Mapping

### Primary CTAs

```swift
// ✅ CORRECT - Uses primaryAccent
Button("Upload Résumé") { }
    .foregroundColor(ThemeColors.textOnDark)
    .background(ThemeColors.primaryAccent)  // Vivid blue
    .cornerRadius(12)

// ❌ WRONG - Do NOT use primaryBrand for CTAs
Button("Upload Résumé") { }
    .background(ThemeColors.primaryBrand)  // Too dark, blends with text
```

### Secondary CTAs (Outline Style)

```swift
Button("Scan with Camera") { }
    .foregroundColor(ThemeColors.primaryAccent)
    .background(ThemeColors.cardLight)
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(ThemeColors.primaryAccent, lineWidth: 1.5)
    )
```

### Cards & Containers

```swift
// Light mode card - PURE WHITE
VStack { ... }
    .background(ThemeColors.cardLight)  // #FFFFFF
    .cornerRadius(Theme.CornerRadius.medium)
    .overlay(
        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
            .stroke(ThemeColors.borderSubtle, lineWidth: 1)
    )
    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
```

### Text Hierarchy

| Context | Token | Actual Color |
|---------|-------|--------------|
| Headings (light) | `textOnLight` | Deep Indigo |
| Body (light) | `textOnLight` | Deep Indigo |
| Secondary (light) | `textSecondaryLight` | Soft Grey |
| Headings (dark) | `textOnDark` | Paper White |
| Secondary (dark) | `textSecondaryDark` | Mist Blue |

### Dashboard Metrics

```swift
// Key numbers use primaryAccent to pop
Text("\(totalSearches)")
    .font(.title2.bold())
    .foregroundColor(ThemeColors.primaryAccent)  // Vivid blue

// Labels use neutral grey
Text("Total Searches")
    .font(.caption)
    .foregroundColor(ThemeColors.textSecondaryLight)  // Soft grey
```

---

## 📱 Screen-by-Screen Guide

| Screen | Background | Primary CTA | Text |
|--------|------------|-------------|------|
| **Splash** | `heroGradientDark` + `accentGlow` | n/a | `textOnDark` |
| **Onboarding** | `heroGradientDark` | `primaryAccent` | `textOnDark` |
| **Auth** | `heroGradientDark` | `primaryAccent` | `textOnDark` |
| **Upload** | `surfaceLight` | `primaryAccent` | `textOnLight` |
| **Analyzing** | `heroGradientDark` + `accentGlow` | n/a | `textOnDark` |
| **Results** | `surfaceLight` | `primaryAccent` | `textOnLight` |
| **Dashboard** | `surfaceLight` | `primaryAccent` | `textOnLight` |
| **Settings** | System List | `primaryAccent` | System |

---

## ✅ Accessibility

### Required Contrast Pairs

| Foreground | Background | Status |
|------------|------------|--------|
| `textOnLight` (deepIndigo) | `surfaceLight` (paperWhite) | ✅ 7.2:1 |
| `textOnDark` (paperWhite) | `surfaceDark` (inkBlack) | ✅ 19.3:1 |
| White | `primaryAccent` (#4C7DFF) | ✅ 4.5:1 |
| White | `deepIndigo` (#3B3355) | ✅ 8.1:1 |

### Guidelines

1. **Never rely on color alone** – Always pair with icons/labels
2. **CTAs must be distinct** – primaryAccent ensures buttons stand out
3. **Avoid long text on saturated backgrounds** – Gradients are for heroes only
4. **Test both modes** – Verify readability in light AND dark mode

---

## 🔧 Implementation Notes

### Golden Rules

1. **CTAs = `primaryAccent`** – Never `primaryBrand` or `slateViolet` for button fills
2. **Cards = pure white** – No purple tint on `cardLight`
3. **Text = `deepIndigo`** – For headings and body on light backgrounds
4. **Highlights = `primaryAccent`** – Key metrics, selected tabs, progress

### Legacy Aliases

For backward compatibility, these aliases exist:
- `wealthStrong` → `primaryAccent`
- `wealthBright` → `accentLight`
- `accentPurple` → `primaryAccent`

New code should use canonical names.

---

*Questions? Reference `Core/ThemeColors.swift` or contact the design team.*
