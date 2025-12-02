//
//  ThemeColors.swift
//  JobMatchNow
//
//  CANONICAL COLOR PALETTE - PALETTE A (CORRECTED)
//  ================================================
//  Cool indigo/violet system. ALL colors from this palette only.
//  NO off-palette blues, NO system colors.
//
//  KEY TOKENS:
//  - primaryBrand (deepIndigo) = brand text, icons, headings
//  - primaryAccent (bright violet) = CTAs, highlights, interactive elements
//  - All surfaces are neutral (white/grey)
//
//  For design rationale: see Docs/ColorPalette.md
//

import SwiftUI

// MARK: - ThemeColors Namespace

enum ThemeColors {
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Core Palette A Colors
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Ink Black** – Near-black for dark mode backgrounds.
    /// Use for: Dark mode shells, gradient dark end.
    static let inkBlack = Color(hex: 0x000505)
    
    /// **Deep Indigo** – Primary brand identity color.
    /// Use for: Brand text, headings, icons – NOT for CTA backgrounds.
    static let deepIndigo = Color(hex: 0x3B3355)
    
    /// **Slate Violet** – Mid-tone purple-grey.
    /// Use for: Secondary text on dark, inactive states, supporting UI.
    static let slateViolet = Color(hex: 0x5D5D81)
    
    /// **Mist Blue** – Soft cool accent.
    /// Use for: Soft backgrounds, badges, subtle highlights.
    static let mistBlue = Color(hex: 0xBFCDE0)
    
    /// **Paper White** – Warm off-white for surfaces.
    /// Use for: Light mode backgrounds, text on dark.
    static let paperWhite = Color(hex: 0xFEFCFD)
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Primary Accent (CTA Color)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Primary Accent** – Brighter, more saturated violet for CTAs.
    /// This is slateViolet lightened and saturated to work as a button fill.
    /// ⭐ USE THIS FOR ALL PRIMARY CTAs ⭐
    /// Stays in the purple/indigo family – NO off-palette blues.
    static let primaryAccent = Color(hex: 0x7B6FA2)
    
    /// **Accent Pressed** – Darker variant for pressed/active states.
    static let accentPressed = Color(hex: 0x5D5481)
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Neutral Greys (De-saturated, no blue tint)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Soft Grey** – Secondary text on light backgrounds.
    static let softGrey = Color(hex: 0x6B7280)
    
    /// **Border Grey** – Dividers, card borders.
    static let borderGrey = Color(hex: 0xE5E7EB)
    
    /// **Surface Grey Dark** – Dark mode cards/elevated surfaces.
    static let surfaceGreyDark = Color(hex: 0x1A1B26)
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Surfaces & Backgrounds (NEUTRAL)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Surface Light** – Main page background (light mode).
    static let surfaceLight = paperWhite
    
    /// **Surface White** – Pure white for cards.
    static let surfaceWhite = Color(hex: 0xFFFFFF)
    
    /// **Surface Dark** – Main background (dark mode).
    static let surfaceDark = inkBlack
    
    /// **Card Light** – Card backgrounds (light mode). Pure white.
    static let cardLight = Color(hex: 0xFFFFFF)
    
    /// **Card Dark** – Card backgrounds (dark mode).
    static let cardDark = surfaceGreyDark
    
    /// **Border Subtle** – Dividers and borders.
    static let borderSubtle = borderGrey
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Semantic Brand Tokens
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Primary Brand** – Brand identity for TEXT and ICONS.
    /// Maps to: deepIndigo
    static var primaryBrand: Color { deepIndigo }
    
    /// **Primary CTA** – Main interactive/clickable element color.
    /// Maps to: primaryAccent (bright violet)
    static var primaryCTA: Color { primaryAccent }
    
    /// **Secondary CTA** – For secondary buttons (outline style).
    /// Maps to: primaryAccent
    static var secondaryCTA: Color { primaryAccent }
    
    /// **Primary Complement** – Supporting brand tone.
    static var primaryComplement: Color { slateViolet }
    
    /// **Soft Complement** – Soft accent for badges, subtle fills.
    static var softComplement: Color { mistBlue }
    
    /// **Deep Complement** – Dark anchor color.
    static var deepComplement: Color { inkBlack }
    
    /// **Midnight** – Alias for deep dark backgrounds.
    static var midnight: Color { inkBlack }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Text Colors
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Text on Light** – Primary text for light backgrounds.
    static let textOnLight = deepIndigo
    
    /// **Text on Dark** – Primary text for dark backgrounds.
    static let textOnDark = paperWhite
    
    /// **Text Secondary Light** – Secondary/muted text on light.
    static let textSecondaryLight = softGrey
    
    /// **Text Secondary Dark** – Secondary text on dark.
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
    
    /// **Info** – Informational (uses slateViolet to stay on palette).
    static let info = slateViolet
    
    // Semantic Aliases
    static var destructive: Color { errorRed }
    static var warning: Color { warningAmber }
    static var success: Color { successGreen }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Legacy Compatibility Aliases
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static var wealthDark: Color { inkBlack }
    static var wealthDeep: Color { surfaceGreyDark }
    static var wealthStrong: Color { primaryAccent }
    static var wealthBright: Color { primaryAccent }
    static var wealthLight: Color { mistBlue }
    static var accentPurple: Color { primaryAccent }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Soft Background Gradients (Palette A Only)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Intro Gradient** – Soft gradient for splash/intro screens.
    /// Smooth transition: inkBlack → deepIndigo → slateViolet (soft dusk sky feel)
    static let introGradient = LinearGradient(
        colors: [
            inkBlack,
            deepIndigo,
            slateViolet.opacity(0.85)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// **Loading Gradient** – Soft gradient for analyzing/loading screens.
    /// Similar to intro but with subtle mistBlue tint at bottom.
    static let loadingGradient = LinearGradient(
        colors: [
            inkBlack,
            deepIndigo,
            slateViolet.opacity(0.7),
            mistBlue.opacity(0.15)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// **Brand Gradient** – Full palette sweep for marketing/hero.
    static let brandGradient = LinearGradient(
        colors: [inkBlack, deepIndigo, slateViolet, mistBlue.opacity(0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// **Dark Gradient** – Simple dark gradient.
    static let darkGradient = LinearGradient(
        colors: [inkBlack, deepIndigo],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// **Light Gradient** – Soft gradient for light mode.
    static let lightGradient = LinearGradient(
        colors: [mistBlue.opacity(0.2), paperWhite],
        startPoint: .top,
        endPoint: .bottom
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
                Text("Palette A Colors")
                    .font(.largeTitle.bold())
                    .foregroundColor(ThemeColors.textOnLight)
                
                // Core Palette
                VStack(alignment: .leading, spacing: 12) {
                    Text("Core Palette A")
                        .font(.headline)
                    colorRow("inkBlack", ThemeColors.inkBlack)
                    colorRow("deepIndigo", ThemeColors.deepIndigo)
                    colorRow("slateViolet", ThemeColors.slateViolet)
                    colorRow("mistBlue", ThemeColors.mistBlue)
                    colorRow("paperWhite", ThemeColors.paperWhite)
                }
                
                // Primary Accent
                VStack(alignment: .leading, spacing: 12) {
                    Text("Primary Accent (CTAs)")
                        .font(.headline)
                    colorRow("primaryAccent", ThemeColors.primaryAccent)
                    colorRow("accentPressed", ThemeColors.accentPressed)
                }
                
                // Gradients
                VStack(alignment: .leading, spacing: 12) {
                    Text("Gradients")
                        .font(.headline)
                    gradientRow("introGradient", ThemeColors.introGradient)
                    gradientRow("loadingGradient", ThemeColors.loadingGradient)
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
                .frame(width: 50, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ThemeColors.borderSubtle, lineWidth: 1)
                )
            Text(name)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(ThemeColors.textOnLight)
            Spacer()
        }
    }
    
    private func gradientRow(_ name: String, _ gradient: LinearGradient) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(ThemeColors.textOnLight)
            RoundedRectangle(cornerRadius: 8)
                .fill(gradient)
                .frame(height: 40)
        }
    }
}

#Preview {
    ThemeColorsPreview()
}
#endif
