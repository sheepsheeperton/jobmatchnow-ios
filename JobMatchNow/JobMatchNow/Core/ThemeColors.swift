//
//  ThemeColors.swift
//  JobMatchNow
//
//  CANONICAL COLOR PALETTE — TRIADIC SYSTEM
//  =========================================
//  Purple (brand) + Green-Teal (actions) + Warm Sand (accents)
//
//  HIERARCHY:
//  - Purple family: typography, icons, brand identity
//  - Green-teal: primary CTAs, key actions, important metrics
//  - Warm sand: soft highlights, secondary surfaces, subtle chips
//  - Neutrals: backgrounds, cards, borders
//
//  For design rationale: see Docs/ColorPalette.md
//

import SwiftUI

// MARK: - ThemeColors Namespace

enum ThemeColors {
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Core Triadic Palette
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    // MARK: Purple Family (Brand)
    
    /// **Brand Purple Dark** – Primary brand color for headings, icons, key labels.
    /// Use for: Typography, icons, brand identity (NOT for CTA fills).
    static let brandPurpleDark = Color(hex: 0x3B3355)
    
    /// **Brand Purple Mid** – Secondary brand tone for structure.
    /// Use for: Secondary text on dark, inactive states, dark mode structure.
    static let brandPurpleMid = Color(hex: 0x5D5D81)
    
    // MARK: Green-Teal (Primary Action)
    
    /// **Accent Green** – Primary CTA / action color.
    /// ⭐ USE THIS FOR ALL PRIMARY CTAs ⭐
    /// Use for: Buttons, key actions, important metrics.
    static let accentGreen = Color(hex: 0x52885E)
    
    /// **Accent Green Pressed** – Darker variant for pressed states.
    static let accentGreenPressed = Color(hex: 0x3D6847)
    
    // MARK: Warm Sand (Secondary Accent)
    
    /// **Accent Sand** – Soft warm neutral accent.
    /// Use for: Soft backgrounds, subtle chips, gentle highlights.
    static let accentSand = Color(hex: 0xF5EEE4)
    
    /// **Accent Sand Dark** – Slightly darker sand for borders/hover.
    static let accentSandDark = Color(hex: 0xE8DFD2)
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Neutrals
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Surface Light** – Main light mode background (off-white).
    static let surfaceLight = Color(hex: 0xF9FAFB)
    
    /// **Surface White** – Pure white for cards.
    static let surfaceWhite = Color(hex: 0xFFFFFF)
    
    /// **Surface Dark** – Deep neutral for dark mode backgrounds.
    static let surfaceDark = Color(hex: 0x0A0A0F)
    
    /// **Card Light** – Card backgrounds (light mode). Pure white.
    static let cardLight = Color(hex: 0xFFFFFF)
    
    /// **Card Dark** – Card backgrounds (dark mode). Deep but not pure black.
    static let cardDark = Color(hex: 0x1A1B26)
    
    /// **Border Subtle** – Light neutral grey for dividers (no purple tint).
    static let borderSubtle = Color(hex: 0xE5E7EB)
    
    /// **Soft Grey** – Medium neutral grey for secondary text.
    static let softGrey = Color(hex: 0x6B7280)
    
    /// **Paper White** – Warm off-white for text on dark.
    static let paperWhite = Color(hex: 0xFEFCFD)
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Semantic Brand Tokens
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Primary Brand** – Brand identity for text and icons.
    /// Maps to: brandPurpleDark
    /// Use for: Headings, icons, key labels (NOT for CTA fills).
    static var primaryBrand: Color { brandPurpleDark }
    
    /// **Primary Accent** – Primary CTA / action color.
    /// Maps to: accentGreen (green-teal)
    /// Use for: Button fills, key actions, important metrics.
    static var primaryAccent: Color { accentGreen }
    
    /// **Secondary Accent** – Soft accent for highlights.
    /// Maps to: accentSand (warm sand)
    /// Use for: Soft backgrounds, subtle chips, gentle highlights.
    static var secondaryAccent: Color { accentSand }
    
    /// **Primary Complement** – Supporting purple tone.
    static var primaryComplement: Color { brandPurpleMid }
    
    /// **Deep Complement** – Dark anchor for structure.
    static var deepComplement: Color { brandPurpleDark }
    
    /// **Midnight** – Deepest dark for backgrounds.
    static var midnight: Color { surfaceDark }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Text Colors
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Text on Light** – Primary text for light backgrounds.
    static let textOnLight = brandPurpleDark
    
    /// **Text on Dark** – Primary text for dark backgrounds.
    static let textOnDark = paperWhite
    
    /// **Text Secondary Light** – Secondary/muted text on light.
    static let textSecondaryLight = softGrey
    
    /// **Text Secondary Dark** – Secondary text on dark.
    static let textSecondaryDark = Color(hex: 0xA0A0B0)
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Utility / Status Colors
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Error Red** – Destructive actions, errors.
    static let errorRed = Color(hex: 0xE74C3C)
    
    /// **Warning Amber** – Warnings, pending states.
    static let warningAmber = Color(hex: 0xF39C12)
    
    /// **Success Green** – Success, completion (distinct from accent).
    static let successGreen = Color(hex: 0x27AE60)
    
    /// **Info** – Informational (uses brand purple to stay on palette).
    static let info = brandPurpleMid
    
    // Semantic Aliases
    static var destructive: Color { errorRed }
    static var warning: Color { warningAmber }
    static var success: Color { successGreen }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Legacy Compatibility Aliases
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    // These map old token names to the new triadic system
    static var inkBlack: Color { surfaceDark }
    static var deepIndigo: Color { brandPurpleDark }
    static var slateViolet: Color { brandPurpleMid }
    static var mistBlue: Color { accentSand } // Replaced with sand
    static var primaryCTA: Color { accentGreen }
    static var secondaryCTA: Color { accentGreen }
    static var borderGrey: Color { borderSubtle }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Gradients (Dark Screens)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Intro Gradient** – Soft gradient for splash/intro screens.
    /// Built from surfaceDark and darkened brandPurpleDark.
    static let introGradient = LinearGradient(
        colors: [
            surfaceDark,
            brandPurpleDark.opacity(0.8),
            brandPurpleMid.opacity(0.6)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// **Loading Gradient** – Soft gradient for analyzing/loading screens.
    static let loadingGradient = LinearGradient(
        colors: [
            surfaceDark,
            brandPurpleDark.opacity(0.9),
            brandPurpleMid.opacity(0.5)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// **Dark Gradient** – Simple dark background gradient.
    static let darkGradient = LinearGradient(
        colors: [surfaceDark, brandPurpleDark.opacity(0.7)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// **Light Gradient** – Soft gradient for light mode emphasis.
    static let lightGradient = LinearGradient(
        colors: [accentSand.opacity(0.3), surfaceLight],
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
                Text("Triadic Palette")
                    .font(.largeTitle.bold())
                    .foregroundColor(ThemeColors.textOnLight)
                
                // Purple Family
                VStack(alignment: .leading, spacing: 12) {
                    Text("Purple (Brand)")
                        .font(.headline)
                    colorRow("brandPurpleDark", ThemeColors.brandPurpleDark)
                    colorRow("brandPurpleMid", ThemeColors.brandPurpleMid)
                }
                
                // Green-Teal
                VStack(alignment: .leading, spacing: 12) {
                    Text("Green-Teal (Actions)")
                        .font(.headline)
                    colorRow("accentGreen", ThemeColors.accentGreen)
                    colorRow("accentGreenPressed", ThemeColors.accentGreenPressed)
                }
                
                // Warm Sand
                VStack(alignment: .leading, spacing: 12) {
                    Text("Warm Sand (Accent)")
                        .font(.headline)
                    colorRow("accentSand", ThemeColors.accentSand)
                    colorRow("accentSandDark", ThemeColors.accentSandDark)
                }
                
                // Neutrals
                VStack(alignment: .leading, spacing: 12) {
                    Text("Neutrals")
                        .font(.headline)
                    colorRow("surfaceLight", ThemeColors.surfaceLight)
                    colorRow("cardLight", ThemeColors.cardLight)
                    colorRow("borderSubtle", ThemeColors.borderSubtle)
                    colorRow("softGrey", ThemeColors.softGrey)
                }
                
                // Button Example
                VStack(alignment: .leading, spacing: 12) {
                    Text("Button Example")
                        .font(.headline)
                    
                    Button("Primary CTA") {}
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnDark)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeColors.primaryAccent)
                        .cornerRadius(12)
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
}

#Preview {
    ThemeColorsPreview()
}
#endif
