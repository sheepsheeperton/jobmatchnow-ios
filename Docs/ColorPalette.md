# JobMatchNow Color Palette

> **Last Updated:** December 2025  
> **Swift Reference:** `JobMatchNow/Core/ThemeColors.swift`  
> **System:** Triadic Palette — Purple (brand) + Green-Teal (actions) + Warm Sand (accents)

---

## 🎨 Overview

JobMatchNow uses a **triadic color palette** designed to create clear visual hierarchy:

| Role | Color Family | Purpose |
|------|--------------|---------|
| **Brand** | Purple | Typography, icons, brand identity |
| **Actions** | Green-Teal | CTAs, buttons, key metrics |
| **Accents** | Warm Sand | Soft highlights, secondary surfaces |
| **Neutrals** | White/Grey | Backgrounds, cards, borders |

### Why This System?

- **Reduces purple overload** — Purple is reserved for brand text/icons, not CTAs
- **Sharpens CTAs** — Green-teal buttons clearly stand out as actionable
- **Adds warmth** — Sand accents soften the UI without competing with actions
- **Clear hierarchy** — Each color family has a distinct purpose

---

## 🎨 Core Palette

### Purple Family (Brand)

| Token | Hex | Role |
|-------|-----|------|
| **brandPurpleDark** | `#3B3355` | Primary brand — headings, icons, key labels |
| **brandPurpleMid** | `#5D5D81` | Secondary — structure, inactive states, dark mode |

### Green-Teal (Primary Actions)

| Token | Hex | Role |
|-------|-----|------|
| **accentGreen** | `#52885E` | ⭐ **Primary CTA** — buttons, key actions, metrics |
| **accentGreenPressed** | `#3D6847` | Pressed/active button states |

### Warm Sand (Secondary Accents)

| Token | Hex | Role |
|-------|-----|------|
| **accentSand** | `#F5EEE4` | Soft backgrounds, subtle chips, highlights |
| **accentSandDark** | `#E8DFD2` | Borders, hover states on sand surfaces |

### Neutrals

| Token | Hex | Role |
|-------|-----|------|
| **surfaceLight** | `#F9FAFB` | Light mode page background |
| **surfaceWhite** | `#FFFFFF` | Card backgrounds (light mode) |
| **surfaceDark** | `#0A0A0F` | Dark mode page background |
| **cardLight** | `#FFFFFF` | Cards (light mode) |
| **cardDark** | `#1A1B26` | Cards (dark mode) |
| **borderSubtle** | `#E5E7EB` | Dividers, card borders |
| **softGrey** | `#6B7280` | Secondary text |
| **paperWhite** | `#FEFCFD` | Text on dark backgrounds |

### Utility / Status Colors

| Token | Hex | Role |
|-------|-----|------|
| **errorRed** | `#E74C3C` | Errors, destructive actions |
| **warningAmber** | `#F39C12` | Warnings, pending states |
| **successGreen** | `#27AE60` | Success, completion |

---

## 📐 Semantic Token Mapping

| Semantic Token | Maps To | Role |
|----------------|---------|------|
| `primaryBrand` | `brandPurpleDark` | Brand text, icons (NOT CTAs) |
| `primaryAccent` | `accentGreen` | Primary CTA / action color |
| `secondaryAccent` | `accentSand` | Soft highlights, chips |
| `textOnLight` | `brandPurpleDark` | Text on light backgrounds |
| `textOnDark` | `paperWhite` | Text on dark backgrounds |
| `textSecondaryLight` | `softGrey` | Secondary text (light) |
| `textSecondaryDark` | `#A0A0B0` | Secondary text (dark) |

---

## 📊 60-30-10 Distribution

### Light Mode

| Percentage | Colors | Usage |
|------------|--------|-------|
| **60%** | Neutrals (surfaceLight, cardLight) | Page backgrounds, cards |
| **25-30%** | Purple (brandPurpleDark, brandPurpleMid) | Typography, icons, structure |
| **10-15%** | Green + Sand | CTAs, highlights, badges |

### Dark Mode

| Percentage | Colors | Usage |
|------------|--------|-------|
| **60%** | Dark neutrals (surfaceDark, cardDark) | Backgrounds |
| **25-30%** | Purple family | Structure, text hierarchy |
| **10-15%** | Green + Sand | CTAs, accents |

---

## 🔘 Component Mapping

### Buttons & CTAs

#### Primary CTAs

```swift
// "Choose Résumé File", "View Details", "Start a Search"
Button("Primary Action") { }
    .foregroundColor(ThemeColors.textOnDark)
    .background(ThemeColors.accentGreen)  // Green CTA
    .cornerRadius(12)
```

#### Secondary CTAs (Outlined)

```swift
Button("Scan with Camera") { }
    .foregroundColor(ThemeColors.accentGreen)
    .background(ThemeColors.cardLight)
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(ThemeColors.accentGreen, lineWidth: 1.5)
    )
```

#### Tertiary (Text-Only)

```swift
Button("Cancel") { }
    .foregroundColor(ThemeColors.primaryBrand)  // Purple text
```

---

### Typography & Icons

| Element | Color Token |
|---------|-------------|
| Headlines | `primaryBrand` (brandPurpleDark) |
| Body text | `textOnLight` or `textSecondaryLight` |
| Icons (default) | `primaryBrand` |
| Icons (active) | `accentGreen` |
| Company names | `accentGreen` (in job cards) |

---

### Cards

```swift
VStack { ... }
    .background(ThemeColors.cardLight)
    .cornerRadius(Theme.CornerRadius.medium)
    .overlay(
        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
            .stroke(ThemeColors.borderSubtle, lineWidth: 1)
    )
    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
```

---

### Badges & Chips

| Badge Type | Background | Text |
|------------|------------|------|
| Direct match | `accentGreen` | `textOnDark` |
| Remote / Local | `accentSand` | `primaryBrand` |
| Error state | `errorRed` | `textOnDark` |

---

### Segmented Controls / Tabs

| State | Background | Text |
|-------|------------|------|
| Active segment | `accentGreen` | `textOnDark` |
| Inactive segment | Clear | `textOnLight` |

---

### Metrics & Numbers

| Context | Color |
|---------|-------|
| Key metrics (Jobs Found, Total) | `accentGreen` |
| Supporting numbers | `primaryBrand` or `softGrey` |
| Secondary stats | `softGrey` |

---

## 📱 Screen-by-Screen Guide

### Upload Screen (Light)

| Element | Token |
|---------|-------|
| Background | `surfaceLight` |
| Title | `primaryBrand` |
| Hero icon circle | `accentSand` |
| Hero icon | `primaryBrand` |
| Primary CTA | `accentGreen` fill, `textOnDark` text |
| Secondary CTA | `cardLight` fill, `accentGreen` border/text |
| Last Search card | `cardLight`, `borderSubtle` |

### Results Screen (Light)

| Element | Token |
|---------|-------|
| Background | `surfaceLight` |
| Page title | `primaryBrand` |
| Job title | `primaryBrand` |
| Company name | `accentGreen` |
| "Why this matches" strip | `accentSand` background |
| "View Details" button | `accentGreen` fill |
| Remote badge | `accentSand` fill, `primaryBrand` text |

### Dashboard (Light)

| Element | Token |
|---------|-------|
| Background | `surfaceLight` |
| Section titles | `primaryBrand` |
| Metric cards | `cardLight`, `borderSubtle` |
| Key numbers | `accentGreen` |
| Session titles | `primaryBrand` |

### Splash / Analyzing (Dark)

| Element | Token |
|---------|-------|
| Background | `introGradient` or `loadingGradient` |
| Title text | `textOnDark` |
| Subtitle | `textSecondaryDark` |
| Logo icon | `accentSand` |
| Progress indicator | `accentSand` |
| Completed steps | `accentGreen` fill, white check |
| In-progress steps | `accentGreen` ring, `accentSand` spinner |
| Pending steps | `brandPurpleMid` at low opacity |

---

## ✅ Do's and Don'ts

### ✅ DO

- Use **green-teal** (`accentGreen`) for all primary CTAs and key metrics
- Use **purple** (`primaryBrand`) for headings, icons, and brand text
- Use **sand** (`accentSand`) for soft highlights and subtle badges
- Keep cards **white** with neutral borders
- Use gradients only on dark screens (splash, analyzing)

### ❌ DON'T

- Use purple as button background for primary actions
- Use green for typography or brand identity
- Introduce new blues, oranges, or off-palette colors
- Put long text on saturated green or purple backgrounds
- Use sand as a primary action color

---

## 🎯 Accessibility

### Contrast Requirements

| Pair | Status |
|------|--------|
| `textOnDark` on `accentGreen` | ✅ Pass WCAG AA |
| `textOnLight` on `surfaceLight` | ✅ Pass WCAG AAA |
| `textOnDark` on `surfaceDark` | ✅ Pass WCAG AAA |
| `primaryBrand` on `accentSand` | ✅ Pass WCAG AA |

### Guidelines

1. **Color is not the only indicator** — pair with icons and labels
2. **Test in both modes** — light and dark
3. **Avoid long text on saturated colors** — keep on neutral surfaces

---

## 🔧 Implementation Notes

### Single Source of Truth

All colors must be defined in `Core/ThemeColors.swift`. Never use hard-coded hex values in views.

```swift
// ✅ Correct
.foregroundColor(ThemeColors.primaryBrand)
.background(ThemeColors.accentGreen)

// ❌ Wrong
.foregroundColor(Color(hex: 0x3B3355))
.background(Color.green)
```

### No Legacy Colors

The following are **deprecated** and should not be used:
- Atomic Tangerine (`#FF7538`)
- Old blues (`#38A1FF`, `#005D8A`, etc.)
- System colors (`.blue`, `.systemBlue`)

---

*All colors from `Core/ThemeColors.swift`. No exceptions.*
