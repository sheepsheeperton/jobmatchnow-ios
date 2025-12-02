# JobMatchNow Color Palette

> **Last Updated:** December 2025  
> **Swift Reference:** `JobMatchNow/Core/ThemeColors.swift`  
> **System:** Palette A – Strict On-Palette Colors Only

This document describes the official JobMatchNow brand color palette. **ALL colors must come from Palette A. No off-palette blues or system colors.**

---

## ⚠️ Important Rules

1. **NO off-palette blues** – Do not use `systemBlue`, `.blue`, or any hex outside Palette A
2. **NO halos/glows around buttons or icons** – Use simple filled or outlined shapes
3. **Soft gradients are OK** – Use `introGradient` and `loadingGradient` for splash/analyzing screens
4. **All surfaces are neutral** – White/grey only, not purple-tinted

---

## 🎨 Core Palette A

| Token | Hex | Role |
|-------|-----|------|
| **inkBlack** | `#000505` | Dark mode backgrounds, gradient dark end |
| **deepIndigo** | `#3B3355` | Brand text, headings, icons |
| **slateViolet** | `#5D5D81` | Secondary text on dark, inactive states |
| **mistBlue** | `#BFCDE0` | Soft backgrounds, badges, subtle highlights |
| **paperWhite** | `#FEFCFD` | Light mode backgrounds, text on dark |

---

## ⭐ Primary Accent (CTAs)

| Token | Hex | Role |
|-------|-----|------|
| **primaryAccent** | `#7B6FA2` | **All primary CTAs**, highlights, selected states |
| **accentPressed** | `#5D5481` | Pressed/active button states |

The `primaryAccent` is a brighter, more saturated version of `slateViolet` that works well as a button fill on both light and dark backgrounds. **It stays in the purple/indigo family – NO off-palette blues.**

---

## 🔘 Neutral Greys

| Token | Hex | Role |
|-------|-----|------|
| **softGrey** | `#6B7280` | Secondary text on light backgrounds |
| **borderGrey** | `#E5E7EB` | Dividers, card borders |
| **surfaceGreyDark** | `#1A1B26` | Dark mode cards |

These are neutral, not purple or blue-tinted.

---

## 📐 Semantic Token Map

| Token | Maps To | Role |
|-------|---------|------|
| `primaryBrand` | `deepIndigo` | Brand text, icons (NOT for CTAs) |
| `primaryCTA` | `primaryAccent` | Button fills, key actions |
| `secondaryCTA` | `primaryAccent` | Outline button border/text |
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

## 🌈 Gradients

### `introGradient` – Soft Intro/Splash Gradient

**Stops:** `inkBlack` → `deepIndigo` → `slateViolet` (85% opacity)  
**Direction:** Top to bottom

**Usage:**
- Splash screen background
- Auth screen background
- Onboarding screen backgrounds

Creates a calm, deep dusk sky feel. Smooth transitions, no banding.

---

### `loadingGradient` – Soft Loading/Analyzing Gradient

**Stops:** `inkBlack` → `deepIndigo` → `slateViolet` (70%) → `mistBlue` (15%)  
**Direction:** Top to bottom

**Usage:**
- Analyzing/loading screen background

Similar to intro gradient but with subtle mistBlue tint at bottom for "active processing" feel.

---

### Other Gradients

| Name | Stops | Use |
|------|-------|-----|
| `brandGradient` | Ink → Indigo → Violet → Mist (50%) | Marketing/hero sections |
| `darkGradient` | Ink → Indigo | Simple dark background |
| `lightGradient` | Mist (20%) → Paper | Light mode soft emphasis |

---

## 📱 Component Guidelines

### Primary CTAs

```swift
// ✅ CORRECT
Button("Upload Résumé") { }
    .foregroundColor(ThemeColors.textOnDark)
    .background(ThemeColors.primaryAccent)  // Purple from Palette A
    .cornerRadius(12)

// ❌ WRONG – Do NOT use system blue
Button("Upload Résumé") { }
    .background(.blue)  // NO!
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

### Tertiary (Text-Only)

```swift
Button("Cancel") { }
    .foregroundColor(ThemeColors.primaryBrand)  // deepIndigo
```

### Cards

```swift
VStack { ... }
    .background(ThemeColors.cardLight)  // Pure white
    .cornerRadius(Theme.CornerRadius.medium)
    .overlay(
        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
            .stroke(ThemeColors.borderSubtle, lineWidth: 1)
    )
    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
```

### Icons on Dark Screens

```swift
// ✅ CORRECT – Simple circle, no halo
ZStack {
    Circle()
        .fill(ThemeColors.slateViolet.opacity(0.3))
        .frame(width: 120, height: 120)
    
    Image(systemName: "briefcase.fill")
        .font(.system(size: 50))
        .foregroundColor(ThemeColors.mistBlue)
}

// ❌ WRONG – No glows/halos
ThemeColors.accentGlow  // Don't use this
    .frame(width: 300, height: 300)
```

---

## 📱 Screen-by-Screen Guide

| Screen | Background | Primary CTA | Text |
|--------|------------|-------------|------|
| **Splash** | `introGradient` | n/a | `textOnDark` |
| **Onboarding** | `introGradient` | `primaryAccent` | `textOnDark` |
| **Auth** | `introGradient` | `primaryAccent` | `textOnDark` |
| **Upload** | `surfaceLight` | `primaryAccent` | `textOnLight` |
| **Analyzing** | `loadingGradient` | n/a | `textOnDark` |
| **Results** | `surfaceLight` | `primaryAccent` | `textOnLight` |
| **Dashboard** | `surfaceLight` | `primaryAccent` | `textOnLight` |
| **Settings** | System List | `primaryAccent` | System |

---

## ✅ Do's and Don'ts

### ✅ DO

- Use `introGradient` / `loadingGradient` for full-screen backgrounds on dark screens
- Use `primaryAccent` for all CTA button fills
- Use `primaryBrand` (deepIndigo) for text and icons
- Use `cardLight` (white) for card backgrounds with `borderSubtle` borders
- Use `mistBlue.opacity(0.2-0.3)` for soft highlight backgrounds

### ❌ DON'T

- Use `systemBlue`, `.blue`, or any off-palette blue
- Add halos, glows, or radial gradients around buttons/icons
- Tint surfaces with purple – keep them neutral white/grey
- Use `primaryBrand` as CTA button background (too dark, blends with text)

---

## 🔴 Utility / Status Colors

| Token | Hex | Use |
|-------|-----|-----|
| `errorRed` | `#E74C3C` | Errors, destructive actions |
| `warningAmber` | `#F39C12` | Warnings, pending states |
| `successGreen` | `#27AE60` | Success, completions |

These are reserved for status indication ONLY.

---

## ✅ Accessibility

### Contrast Pairs

| Foreground | Background | Status |
|------------|------------|--------|
| `textOnLight` | `surfaceLight` | ✅ Pass |
| `textOnDark` | `inkBlack` | ✅ Pass |
| `paperWhite` | `primaryAccent` | ✅ Pass |
| `paperWhite` | `slateViolet` | ✅ Pass |

### Guidelines

1. Never rely on color alone – pair with icons/labels
2. Keep long text on neutral surfaces
3. Test in both light and dark modes

---

*All colors from `Core/ThemeColors.swift`. No exceptions.*
