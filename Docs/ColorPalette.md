# JobMatchNow Color Palette

> **Last Updated:** November 2025  
> **Swift Reference:** `JobMatchNow/Core/ThemeColors.swift`

This document describes the official JobMatchNow brand color palette. All UI development should reference these tokens to ensure visual consistency across the app.

---

## 🎨 Palette Overview

Our palette follows a **60-30-10 rule** for visual balance:

| Proportion | Category | Purpose |
|------------|----------|---------|
| **~60%** | Neutrals | `surfaceLight`, `surfaceWhite`, `borderSubtle` – backgrounds and containers |
| **~30%** | Structural Blues | `primaryComplement`, `deepComplement`, `midnight` – hierarchy and structure |
| **~10%** | Brand Orange + Warm Accent | `primaryBrand`, `warmAccent` – CTAs, highlights, and emphasis |

---

## 🟠 Brand / CTA

### `primaryBrand` – Atomic Tangerine
| Property | Value |
|----------|-------|
| **Hex** | `#FF7538` |
| **RGB** | 255, 117, 56 |
| **Swift** | `ThemeColors.primaryBrand` |

**Usage:**
- Primary CTA buttons (Upload Résumé, Create Account, Sign In)
- Hero section accents
- Key action states (active, selected tabs)

**Brand Note:**  
Atomic Tangerine is energetic, optimistic, and action-oriented. It signals "do this now" and should be reserved for the most important user actions.

---

## 🔵 Complementary Blues

### `primaryComplement` – Vibrant Sky Blue
| Property | Value |
|----------|-------|
| **Hex** | `#38A1FF` |
| **RGB** | 56, 161, 255 |
| **Swift** | `ThemeColors.primaryComplement` |

**Usage:**
- Secondary CTAs and buttons
- Text links and interactive elements
- Selected/active state indicators
- Accent borders and highlights

**Brand Note:**  
A trustworthy, professional blue that complements our orange. Use for secondary actions that still need visibility.

---

### `softComplement` – Soft Ice Blue
| Property | Value |
|----------|-------|
| **Hex** | `#A1D6FF` |
| **RGB** | 161, 214, 255 |
| **Swift** | `ThemeColors.softComplement` |

**Usage:**
- Light background tints on cards
- Onboarding illustration fills
- Subtle emphasis backgrounds
- Progress bar tracks (unfilled)

**Brand Note:**  
Gentle and approachable. Use at low opacity (10-30%) for subtle visual layers. Never use for text or small icons.

---

### `deepComplement` – Deep Cyan
| Property | Value |
|----------|-------|
| **Hex** | `#005D8A` |
| **RGB** | 0, 93, 138 |
| **Swift** | `ThemeColors.deepComplement` |

**Usage:**
- Dark mode card backgrounds
- Navigation bar in dark mode
- Modal overlays
- Footer sections

**Brand Note:**  
Professional depth without being as heavy as pure black. Creates a rich dark mode experience.

---

### `midnight` – Midnight Navy
| Property | Value |
|----------|-------|
| **Hex** | `#0D3A6A` |
| **RGB** | 13, 58, 106 |
| **Swift** | `ThemeColors.midnight` |

**Usage:**
- Primary text on light backgrounds
- Headlines and titles
- Dark mode surface color
- Icon fills on light mode

**Brand Note:**  
Our "text black" – warmer and more branded than pure black. Creates a cohesive feel when used throughout.

---

## 🟡 Warm Accent

### `warmAccent` – Warm Honey
| Property | Value |
|----------|-------|
| **Hex** | `#FFB140` |
| **RGB** | 255, 177, 64 |
| **Swift** | `ThemeColors.warmAccent` |

**Usage:**
- Warning states (not errors)
- Subtle highlights and badges
- Chart/data visualization accents
- Star ratings and achievements

**Brand Note:**  
A softer, warmer alternative to orange. Use when you need emphasis without the urgency of a CTA.

---

## ⬜ Neutrals

### `surfaceLight` – Light Gray Surface
| Property | Value |
|----------|-------|
| **Hex** | `#F9F9F9` |
| **RGB** | 249, 249, 249 |
| **Swift** | `ThemeColors.surfaceLight` |

**Usage:**
- Main app background (light mode)
- Page-level container
- List backgrounds

---

### `surfaceWhite` – Pure White
| Property | Value |
|----------|-------|
| **Hex** | `#FFFFFF` |
| **RGB** | 255, 255, 255 |
| **Swift** | `ThemeColors.surfaceWhite` |

**Usage:**
- Card backgrounds
- Modal surfaces
- Input field backgrounds
- Elevated content containers

---

### `borderSubtle` – Subtle Border Gray
| Property | Value |
|----------|-------|
| **Hex** | `#E5E7EB` |
| **RGB** | 229, 231, 235 |
| **Swift** | `ThemeColors.borderSubtle` |

**Usage:**
- Dividers and separators
- Input field borders
- Card outlines (when needed)
- Table row separators

---

## 🔴 Utility

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

**Note:** Use sparingly. This color demands attention and should only appear for genuine errors or destructive actions.

---

### `textOnLight` – Text on Light
| Property | Value |
|----------|-------|
| **Hex** | `#0D3A6A` |
| **RGB** | 13, 58, 106 |
| **Swift** | `ThemeColors.textOnLight` |

**Usage:**
- Body text on light backgrounds
- Labels and descriptions
- Navigation titles

**Note:** This is an alias for `midnight`. Use whichever name is more semantically appropriate.

---

### `textOnDark` – Text on Dark
| Property | Value |
|----------|-------|
| **Hex** | `#F9F9F9` |
| **RGB** | 249, 249, 249 |
| **Swift** | `ThemeColors.textOnDark` |

**Usage:**
- Body text on dark backgrounds
- Button labels on `primaryBrand`, `deepComplement`, etc.
- Dark mode text

---

## 📐 Usage Guidelines

### Button Hierarchy

| Level | Background | Text |
|-------|------------|------|
| **Primary CTA** | `primaryBrand` | `textOnDark` (white) |
| **Secondary** | `primaryComplement` | `textOnDark` |
| **Tertiary** | `surfaceWhite` + border | `primaryComplement` |
| **Destructive** | `errorRed` | `textOnDark` |

### Text Hierarchy

| Context | Color |
|---------|-------|
| Headlines (light mode) | `midnight` |
| Body text (light mode) | `textOnLight` |
| Secondary text | `midnight` at 60% opacity |
| Text on dark surfaces | `textOnDark` |

### Backgrounds

| Layer | Light Mode | Dark Mode |
|-------|------------|-----------|
| Page background | `surfaceLight` | `midnight` |
| Cards | `surfaceWhite` | `deepComplement` |
| Elevated modals | `surfaceWhite` | `deepComplement` |

---

## 🔧 Implementation

### Swift Usage

```swift
import SwiftUI

struct MyButton: View {
    var body: some View {
        Button("Upload Résumé") {
            // action
        }
        .foregroundColor(ThemeColors.textOnDark)
        .background(ThemeColors.primaryBrand)
        .cornerRadius(12)
    }
}
```

### Semantic Aliases

For common patterns, use the provided aliases:

```swift
ThemeColors.cta          // → primaryBrand
ThemeColors.destructive  // → errorRed
ThemeColors.warning      // → warmAccent
ThemeColors.subtleHighlight  // → softComplement at 30% opacity
```

---

## ✅ Checklist for New UI Work

- [ ] Use `ThemeColors.xyz` instead of hardcoded hex values
- [ ] Follow the 60-30-10 balance rule
- [ ] Test on both light and dark backgrounds
- [ ] Ensure sufficient contrast for accessibility (4.5:1 for text)
- [ ] Use `primaryBrand` only for primary CTAs
- [ ] Use `errorRed` only for actual errors or destructive actions

---

*Questions? Contact the design team or reference this document.*

