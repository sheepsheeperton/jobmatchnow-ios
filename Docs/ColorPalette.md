# JobMatchNow Color Palette

> **Last Updated:** December 2025  
> **Swift Reference:** `JobMatchNow/Core/ThemeColors.swift`  
> **System:** Green Wealth + Complementary Purple

This document describes the official JobMatchNow brand color palette. Our green-based system evokes **wealth, growth, and professional trust**, with complementary purple for visual variety.

---

## 🌱 Palette Philosophy

**Why Green?**  
Green symbolizes **growth, prosperity, and stability** – perfect for a career advancement platform. Our palette ranges from deep forest greens (professionalism) to bright spring greens (optimism and opportunity).

**60-30-10 Rule:**

| Proportion | Category | Colors |
|------------|----------|--------|
| **~60%** | Neutral Surfaces | `surfaceLight`, `cardLight`, `borderSubtle` |
| **~30%** | Wealth Greens | `wealthDark`, `wealthDeep`, `wealthStrong` |
| **~10%** | Accent & CTA | `wealthBright`, `accentPurple` |

---

## 🟢 Core Wealth Greens

### `wealthDark` – Wealth Dark
| Property | Value |
|----------|-------|
| **Hex** | `#132A13` |
| **RGB** | 19, 42, 19 |
| **Swift** | `ThemeColors.wealthDark` |

**Usage:**
- Primary text on light backgrounds
- Dark mode app background
- Navigation bars and headers (dark mode)
- Footer sections

**Brand Note:**  
Our darkest green serves as "text black" – professional and rooted. Creates strong contrast on light backgrounds while maintaining brand unity.

---

### `wealthDeep` – Wealth Deep
| Property | Value |
|----------|-------|
| **Hex** | `#31572C` |
| **RGB** | 49, 87, 44 |
| **Swift** | `ThemeColors.wealthDeep` |

**Usage:**
- Dark mode card backgrounds
- Modal overlays (dark mode)
- Elevated surfaces in dark mode
- Section backgrounds

**Brand Note:**  
Forest green depth. Provides visual hierarchy in dark mode while staying on-brand.

---

### `wealthStrong` – Wealth Strong ⭐
| Property | Value |
|----------|-------|
| **Hex** | `#4F772D` |
| **RGB** | 79, 119, 45 |
| **Swift** | `ThemeColors.wealthStrong` |

**Usage:**
- **Primary CTA buttons** (Upload Résumé, Sign In, Get Matches)
- Selected tab states
- Active navigation items
- Important badges and highlights
- Progress bar fills

**Brand Note:**  
**This is our hero color.** Strong, confident green that drives action. Use for the most important user interactions.

---

### `wealthBright` – Wealth Bright
| Property | Value |
|----------|-------|
| **Hex** | `#90A955` |
| **RGB** | 144, 169, 85 |
| **Swift** | `ThemeColors.wealthBright` |

**Usage:**
- Secondary buttons
- Hover states
- Progress indicators (unfilled)
- Success states and checkmarks
- Subtle emphasis backgrounds

**Brand Note:**  
Optimistic spring green. Lighter and more approachable than wealthStrong. Perfect for secondary interactions.

---

### `wealthLight` – Wealth Light
| Property | Value |
|----------|-------|
| **Hex** | `#ECF39E` |
| **RGB** | 236, 243, 158 |
| **Swift** | `ThemeColors.wealthLight` |

**Usage:**
- Text on dark backgrounds
- Light accent fills
- Illustration highlights
- Gradient endpoints
- Badge text on dark

**Brand Note:**  
Soft lime glow. Provides excellent readability on dark surfaces. Use at 10-30% opacity for subtle background tints.

---

## 🟣 Complementary Accent

### `accentPurple` – Accent Purple
| Property | Value |
|----------|-------|
| **Hex** | `#532C58` |
| **RGB** | 83, 44, 88 |
| **Swift** | `ThemeColors.accentPurple` |

**Usage:**
- Secondary CTA buttons
- Link text and clickable elements
- Special badges (premium, featured)
- Alert/notification accents (non-error)
- Variety in data visualizations

**Brand Note:**  
Regal purple provides contrast against the green palette. Use sparingly for visual interest and to highlight secondary actions.

---

## ⬜ Surfaces & Backgrounds

### `surfaceLight` – Surface Light
| Property | Value |
|----------|-------|
| **Hex** | `#F8F9F7` |
| **RGB** | 248, 249, 247 |
| **Swift** | `ThemeColors.surfaceLight` |

**Usage:**
- Main app background (light mode)
- Page-level container
- List backgrounds

**Note:** Subtle warm off-white that complements greens without competing.

---

### `surfaceDark` – Surface Dark
| Property | Value |
|----------|-------|
| **Hex** | `#132A13` (same as wealthDark) |
| **RGB** | 19, 42, 19 |
| **Swift** | `ThemeColors.surfaceDark` |

**Usage:**
- Main app background (dark mode)
- Full-screen dark overlays

---

### `cardLight` – Card Light
| Property | Value |
|----------|-------|
| **Hex** | `#FFFFFF` |
| **RGB** | 255, 255, 255 |
| **Swift** | `ThemeColors.cardLight` |

**Usage:**
- Card backgrounds (light mode)
- Modal surfaces
- Input field backgrounds
- Elevated content containers

---

### `cardDark` – Card Dark
| Property | Value |
|----------|-------|
| **Hex** | `#31572C` (same as wealthDeep) |
| **RGB** | 49, 87, 44 |
| **Swift** | `ThemeColors.cardDark` |

**Usage:**
- Card backgrounds (dark mode)
- Modal surfaces (dark mode)
- Input field backgrounds (dark mode)

---

### `borderSubtle` – Border Subtle
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

## 🔴 Utility Colors

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
| **Hex** | `#90A955` (same as wealthBright) |
| **RGB** | 144, 169, 85 |
| **Swift** | `ThemeColors.successGreen` |

**Usage:**
- Success banners
- Completed states
- Positive feedback
- Checkmarks and confirmations

---

## 🎨 Gradient System

### Brand Gradient (Canonical)
**Colors:** `wealthDark` → `wealthStrong` → `wealthBright` → `wealthLight`  
**Swift:** `ThemeColors.brandGradient`

**Usage:**
- Hero sections
- Splash screens
- Onboarding backgrounds
- Premium feature highlights

**Direction:** Top-left to bottom-right

---

### Light Gradient
**Colors:** `wealthStrong` → `wealthBright`  
**Swift:** `ThemeColors.lightGradient`

**Usage:**
- Card backgrounds (light mode emphasis)
- Section headers
- Button hover states

---

### Dark Gradient
**Colors:** `wealthDark` → `wealthDeep`  
**Swift:** `ThemeColors.darkGradient`

**Usage:**
- Dark mode backgrounds
- Navigation bars (dark mode)
- Footer sections

---

### Accent Gradient
**Colors:** `accentPurple` → `wealthBright`  
**Swift:** `ThemeColors.accentGradient`

**Usage:**
- Special emphasis
- Premium badges
- Promotional banners

---

## 📐 Application Guidelines

### Button Hierarchy

| Level | Background | Text | Border |
|-------|------------|------|--------|
| **Primary CTA** | `wealthStrong` | `textOnDark` (wealthLight) | none |
| **Secondary CTA** | `accentPurple` | `textOnDark` | none |
| **Tertiary** | `cardLight` + border | `wealthStrong` | `wealthStrong` (1.5px) |
| **Destructive** | `errorRed` | white | none |
| **Ghost/Text** | transparent | `wealthStrong` | none |

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
    .foregroundColor(ThemeColors.wealthStrong)
    .background(ThemeColors.cardLight)
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(ThemeColors.wealthStrong, lineWidth: 1.5)
    )
```

---

### Text Hierarchy

| Context | Color | Opacity |
|---------|-------|---------|
| **Headline (light mode)** | `textOnLight` | 100% |
| **Body text (light mode)** | `textOnLight` | 100% |
| **Secondary text (light mode)** | `textSecondaryLight` | 100% |
| **Caption (light mode)** | `textOnLight` | 60% |
| **Headline (dark mode)** | `textOnDark` | 100% |
| **Body text (dark mode)** | `textOnDark` | 100% |
| **Secondary text (dark mode)** | `textSecondaryDark` | 100% |

---

### Navigation & Tab Bars

| State | Background | Text/Icon | Indicator |
|-------|------------|-----------|-----------|
| **Active tab** | transparent | `wealthStrong` | `wealthStrong` underline |
| **Inactive tab** | transparent | `textSecondaryLight` | none |
| **Nav bar (light)** | `surfaceLight` | `textOnLight` | - |
| **Nav bar (dark)** | `surfaceDark` | `textOnDark` | - |

---

### Cards & Containers

| Mode | Background | Border | Shadow |
|------|------------|--------|--------|
| **Light mode card** | `cardLight` | `borderSubtle` (optional) | subtle gray |
| **Dark mode card** | `cardDark` | none | none |
| **Elevated modal (light)** | `cardLight` | none | strong shadow |
| **Elevated modal (dark)** | `cardDark` | none | none |

---

### Badges & Pills

| Type | Background | Text |
|------|------------|------|
| **Primary** | `wealthStrong` | `textOnDark` |
| **Success** | `successGreen` | `wealthDark` |
| **Warning** | `warningAmber` | `wealthDark` |
| **Error** | `errorRed` | white |
| **Accent** | `accentPurple` | `textOnDark` |
| **Neutral** | `borderSubtle` | `textOnLight` |

---

## 🔧 Implementation

### Semantic Aliases

Use these convenient aliases for common patterns:

```swift
ThemeColors.primaryBrand   // → wealthStrong
ThemeColors.primaryCTA     // → wealthStrong
ThemeColors.secondaryCTA   // → accentPurple
ThemeColors.destructive    // → errorRed
ThemeColors.warning        // → warningAmber
ThemeColors.success        // → successGreen
```

---

### Dark Mode Support

All colors are designed to work in both light and dark modes:

```swift
// Light mode
.background(ThemeColors.surfaceLight)
.foregroundColor(ThemeColors.textOnLight)

// Dark mode
.background(ThemeColors.surfaceDark)
.foregroundColor(ThemeColors.textOnDark)
```

---

### Gradient Usage

```swift
// Hero section with brand gradient
ZStack {
    ThemeColors.brandGradient
        .ignoresSafeArea()
    
    VStack {
        Text("Find Your Perfect Role")
            .foregroundColor(ThemeColors.textOnDark)
    }
}

// Card with light gradient
RoundedRectangle(cornerRadius: 16)
    .fill(ThemeColors.lightGradient)
    .frame(height: 120)
```

---

## ✅ Migration Checklist

When updating from the old palette:

- [ ] Replace `primaryBrand` (orange) → now `wealthStrong` (green)
- [ ] Replace `primaryComplement` (blue) → now `accentPurple`
- [ ] Replace `softComplement` (light blue) → now `wealthBright`
- [ ] Replace `deepComplement` (dark blue) → now `wealthDeep`
- [ ] Replace `midnight` (navy) → now `wealthDark`
- [ ] Update all gradient references to use new gradient system
- [ ] Test all screens in both light and dark mode
- [ ] Verify text contrast ratios (WCAG AA: 4.5:1 for body text)

---

## 🎯 Quick Reference

**Primary Actions:** `wealthStrong`  
**Secondary Actions:** `accentPurple`  
**Success:** `wealthBright` (successGreen)  
**Warning:** `warningAmber`  
**Error/Destructive:** `errorRed`  
**Text (Light Mode):** `wealthDark`  
**Text (Dark Mode):** `wealthLight`  
**Backgrounds (Light):** `surfaceLight` → `cardLight`  
**Backgrounds (Dark):** `surfaceDark` → `cardDark`

---

*Questions? Contact the design team or reference `Core/ThemeColors.swift`.*
