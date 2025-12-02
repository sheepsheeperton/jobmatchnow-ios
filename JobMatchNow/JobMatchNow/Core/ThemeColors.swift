//
//  ThemeColors.swift
//  JobMatchNow
//
//  CANONICAL COLOR PALETTE - PALETTE A (REBALANCED)
//  =================================================
//  Cool indigo/violet system with VIVID ACCENT for CTAs.
//  
//  KEY DISTINCTION:
//  - primaryBrand (deepIndigo) = brand text, icons, headings
//  - primaryAccent (vibrant blue) = CTAs, highlights, interactive elements
//  - Surfaces are NEUTRAL (white/grey), not purple-tinted
//
//  All SwiftUI views should consume colors via ThemeColors.
//  For design rationale: see Docs/ColorPalette.md
//

import SwiftUI

// MARK: - ThemeColors Namespace

enum ThemeColors {
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Core Palette Colors
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Ink Black** – Near-black for dark mode backgrounds.
    /// Use for: Dark mode shells, splash/analyzing backgrounds.
    static let inkBlack = Color(hex: 0x000505)
    
    /// **Deep Indigo** – Primary brand identity color.
    /// Use for: Brand text, headings, icons – NOT for CTA backgrounds.
    static let deepIndigo = Color(hex: 0x3B3355)
    
    /// **Slate Violet** – Supporting brand tone.
    /// Use for: Secondary text on dark, inactive states, subtle accents.
    static let slateViolet = Color(hex: 0x5D5D81)
    
    /// **Mist Blue** – Soft cool accent.
    /// Use for: Subtle backgrounds, badges, soft highlights.
    static let mistBlue = Color(hex: 0xBFCDE0)
    
    /// **Paper White** – Warm off-white for surfaces.
    /// Use for: Light mode backgrounds, text on dark.
    static let paperWhite = Color(hex: 0xFEFCFD)
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - ⭐ PRIMARY ACCENT (NEW)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Primary Accent** – Vivid blue for CTAs and highlights.
    /// ⭐ THIS IS THE MAIN INTERACTIVE COLOR ⭐
    /// Use for: Primary buttons, key metrics, selected tabs, progress indicators.
    /// Harmonizes with Palette A while popping on both light and dark backgrounds.
    static let primaryAccent = Color(hex: 0x4C7DFF)
    
    /// **Accent Light** – Lighter version for hover/pressed states on dark.
    static let accentLight = Color(hex: 0x7B9FFF)
    
    /// **Accent Dark** – Darker version for pressed states on light.
    static let accentDark = Color(hex: 0x3A5FCC)
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Neutral Greys (De-saturated)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Soft Grey** – Secondary text on light backgrounds.
    /// Neutral, not purple-tinted.
    static let softGrey = Color(hex: 0x6B7280)
    
    /// **Border Grey** – Dividers, card borders.
    /// Neutral cool grey, works on white/paper surfaces.
    static let borderGrey = Color(hex: 0xE5E7EB)
    
    /// **Surface Grey Dark** – Dark mode cards/elevated surfaces.
    /// Slightly lighter than inkBlack for hierarchy.
    static let surfaceGreyDark = Color(hex: 0x1A1B26)
    
    /// **Card Border Dark** – Subtle borders on dark mode cards.
    static let cardBorderDark = Color(hex: 0x2D2E3A)
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Surfaces & Backgrounds (NEUTRAL)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Surface Light** – Main page background (light mode).
    /// Maps to: paperWhite
    static let surfaceLight = paperWhite
    
    /// **Surface White** – Pure white for maximum brightness.
    static let surfaceWhite = Color(hex: 0xFFFFFF)
    
    /// **Surface Dark** – Main background (dark mode).
    /// Maps to: inkBlack
    static let surfaceDark = inkBlack
    
    /// **Card Light** – Elevated card backgrounds (light mode).
    /// PURE WHITE – no purple tint.
    static let cardLight = Color(hex: 0xFFFFFF)
    
    /// **Card Dark** – Elevated card backgrounds (dark mode).
    /// Maps to: surfaceGreyDark
    static let cardDark = surfaceGreyDark
    
    /// **Border Subtle** – Dividers and borders (light mode).
    /// Maps to: borderGrey (neutral)
    static let borderSubtle = borderGrey
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Semantic Brand Tokens
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Primary Brand** – Brand identity for TEXT and ICONS.
    /// ⚠️ NOT for CTA backgrounds – use primaryAccent instead.
    /// Maps to: deepIndigo
    static var primaryBrand: Color { deepIndigo }
    
    /// **Primary CTA** – Main interactive/clickable element color.
    /// Maps to: primaryAccent (vivid blue)
    static var primaryCTA: Color { primaryAccent }
    
    /// **Secondary CTA** – For secondary buttons (outline style).
    /// Maps to: primaryAccent (use as border/text, not fill)
    static var secondaryCTA: Color { primaryAccent }
    
    /// **Primary Complement** – Supporting brand tone.
    /// Maps to: slateViolet
    static var primaryComplement: Color { slateViolet }
    
    /// **Soft Complement** – Soft accent for badges, subtle fills.
    /// Maps to: mistBlue
    static var softComplement: Color { mistBlue }
    
    /// **Deep Complement** – Dark anchor color.
    /// Maps to: inkBlack
    static var deepComplement: Color { inkBlack }
    
    /// **Midnight** – Alias for deep dark backgrounds.
    /// Maps to: inkBlack
    static var midnight: Color { inkBlack }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Text Colors
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Text on Light** – Primary text for light backgrounds.
    /// Maps to: deepIndigo (brand cohesion, high contrast)
    static let textOnLight = deepIndigo
    
    /// **Text on Dark** – Primary text for dark backgrounds.
    /// Maps to: paperWhite (near-white)
    static let textOnDark = paperWhite
    
    /// **Text Secondary Light** – Secondary/muted text on light.
    /// Maps to: softGrey (neutral)
    static let textSecondaryLight = softGrey
    
    /// **Text Secondary Dark** – Secondary text on dark.
    /// Maps to: mistBlue
    static let textSecondaryDark = mistBlue
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Utility / Status Colors
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Error Red** – Destructive actions, errors.
    static let errorRed = Color(hex: 0xE74C3C)
    
    /// **Warning Amber** – Warnings, pending states.
    static let warningAmber = Color(hex: 0xF39C12)
    
    /// **Success Green** – Success, completion.
    static let successGreen = Color(hex: 0x27AE60)
    
    /// **Info Teal** – Informational callouts.
    static let infoTeal = Color(hex: 0x17A2B8)
    
    // Semantic Aliases
    static var destructive: Color { errorRed }
    static var warning: Color { warningAmber }
    static var success: Color { successGreen }
    static var info: Color { infoTeal }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Legacy Compatibility Aliases
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// Legacy aliases for gradual migration
    static var wealthDark: Color { inkBlack }
    static var wealthDeep: Color { surfaceGreyDark }
    static var wealthStrong: Color { primaryAccent } // Updated: CTAs use accent now
    static var wealthBright: Color { accentLight }
    static var wealthLight: Color { mistBlue }
    static var accentPurple: Color { primaryAccent } // Updated: accent is now blue
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Gradient System
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Hero Gradient (Dark)** – Rich gradient for splash/analyzing.
    /// Use for: Splash screen, analyzing screen backgrounds.
    static let heroGradientDark = LinearGradient(
        colors: [inkBlack, deepIndigo, slateViolet.opacity(0.7)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// **Brand Gradient** – Full palette sweep for hero sections.
    static let brandGradient = LinearGradient(
        colors: [inkBlack, deepIndigo, slateViolet, mistBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// **Light Gradient** – Soft gradient for light mode emphasis.
    static let lightGradient = LinearGradient(
        colors: [mistBlue.opacity(0.3), paperWhite],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// **Dark Gradient** – Simple dark gradient.
    static let darkGradient = LinearGradient(
        colors: [inkBlack, deepIndigo],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// **Accent Gradient** – Gradient using the primary accent.
    static let accentGradient = LinearGradient(
        colors: [primaryAccent, accentLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Radial Glow Effects
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Accent Glow** – Radial glow for behind icons on dark screens.
    static let accentGlow = RadialGradient(
        colors: [primaryAccent.opacity(0.4), primaryAccent.opacity(0.0)],
        center: .center,
        startRadius: 0,
        endRadius: 150
    )
    
    /// **Soft Glow** – Subtle radial glow for depth.
    static let softGlow = RadialGradient(
        colors: [slateViolet.opacity(0.3), Color.clear],
        center: .center,
        startRadius: 0,
        endRadius: 200
    )
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize a Color from a hex integer value.
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
    
    /// Initialize a Color from a hex string.
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(hex: UInt(int))
    }
}

// MARK: - Preview Helper

#if DEBUG
struct ThemeColorsPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("JobMatchNow Color Palette")
                    .font(.largeTitle.bold())
                    .foregroundColor(ThemeColors.textOnLight)
                
                // Primary Accent (NEW)
                VStack(alignment: .leading, spacing: 16) {
                    Text("⭐ Primary Accent (CTAs)")
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnLight)
                    
                    colorRow("primaryAccent", ThemeColors.primaryAccent)
                    colorRow("accentLight", ThemeColors.accentLight)
                    colorRow("accentDark", ThemeColors.accentDark)
                }
                
                // Core Palette
                VStack(alignment: .leading, spacing: 16) {
                    Text("Core Palette (Brand)")
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnLight)
                    
                    colorRow("inkBlack", ThemeColors.inkBlack)
                    colorRow("deepIndigo", ThemeColors.deepIndigo)
                    colorRow("slateViolet", ThemeColors.slateViolet)
                    colorRow("mistBlue", ThemeColors.mistBlue)
                    colorRow("paperWhite", ThemeColors.paperWhite)
                }
                
                // Surfaces (Neutral)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Surfaces (Neutral)")
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnLight)
                    
                    colorRow("surfaceLight", ThemeColors.surfaceLight)
                    colorRow("surfaceWhite", ThemeColors.surfaceWhite)
                    colorRow("cardLight", ThemeColors.cardLight)
                    colorRow("borderSubtle", ThemeColors.borderSubtle)
                }
                
                // Utility Colors
                VStack(alignment: .leading, spacing: 16) {
                    Text("Utility Colors")
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnLight)
                    
                    colorRow("errorRed", ThemeColors.errorRed)
                    colorRow("warningAmber", ThemeColors.warningAmber)
                    colorRow("successGreen", ThemeColors.successGreen)
                }
                
                // Gradients
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gradients")
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnLight)
                    
                    gradientRow("heroGradientDark", ThemeColors.heroGradientDark)
                    gradientRow("accentGradient", ThemeColors.accentGradient)
                    gradientRow("lightGradient", ThemeColors.lightGradient)
                }
            }
            .padding()
        }
        .background(ThemeColors.surfaceLight)
    }
    
    private func colorRow(_ name: String, _ color: Color) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ThemeColors.borderSubtle, lineWidth: 1)
                )
            
            Text(name)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(ThemeColors.textOnLight)
            
            Spacer()
        }
    }
    
    private func gradientRow(_ name: String, _ gradient: LinearGradient) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(gradient)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ThemeColors.borderSubtle, lineWidth: 1)
                )
            
            Text(name)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(ThemeColors.textOnLight)
                .frame(width: 150, alignment: .leading)
        }
    }
}

#Preview {
    ThemeColorsPreview()
}
#endif
