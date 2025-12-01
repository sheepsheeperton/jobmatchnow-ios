//
//  ThemeColors.swift
//  JobMatchNow
//
//  CANONICAL COLOR PALETTE - GREEN WEALTH SYSTEM
//  ==============================================
//  This file defines the official JobMatchNow brand color palette.
//  Built around greens (wealth, growth, trust) with complementary purple.
//  
//  All SwiftUI views should consume colors via ThemeColors rather than
//  hard-coded hex values or system colors.
//
//  Usage: ThemeColors.wealthStrong, ThemeColors.accentPurple, etc.
//
//  For design rationale and usage guidelines, see: Docs/ColorPalette.md
//

import SwiftUI

// MARK: - ThemeColors Namespace

/// Canonical JobMatchNow color palette.
/// Green-based system signifying wealth, growth, and professional trust.
/// Use these tokens for all UI elements to ensure brand consistency.
enum ThemeColors {
    
    // MARK: - Core Wealth Greens
    
    /// **Wealth Dark** – Darkest green for dark mode backgrounds and primary text on light.
    /// Use for: Body text on light surfaces, dark mode app background, navigation bars (dark).
    /// This is our "text black" and primary dark surface color.
    static let wealthDark = Color(hex: 0x132A13)
    
    /// **Wealth Deep** – Deep forest green for elevated surfaces in dark mode.
    /// Use for: Dark mode card backgrounds, modal backgrounds, navigation elements in dark mode.
    /// Provides depth while maintaining brand consistency.
    static let wealthDeep = Color(hex: 0x31572C)
    
    /// **Wealth Strong** – Primary brand green for CTAs and emphasis.
    /// Use for: Primary CTA buttons ("Upload Résumé", "Sign In", "Get Matches"),
    /// selected states, active tabs, important highlights.
    /// This is the hero color that drives action.
    static let wealthStrong = Color(hex: 0x4F772D)
    
    /// **Wealth Bright** – Bright mid-tone green for secondary interactive elements.
    /// Use for: Secondary buttons, hover states, progress indicators, badges.
    /// Lighter than wealthStrong but still prominent.
    static let wealthBright = Color(hex: 0x90A955)
    
    /// **Wealth Light** – Lightest green for subtle accents and text on dark backgrounds.
    /// Use for: Text on dark green backgrounds, light accent fills, illustration highlights.
    /// Low saturation; pairs well with wealthDark surfaces.
    static let wealthLight = Color(hex: 0xECF39E)
    
    // MARK: - Complementary Accent
    
    /// **Accent Purple** – Complementary purple for secondary CTAs and variety.
    /// Use for: Secondary call-to-actions, special badges, alerts (non-error), links.
    /// Provides visual contrast against the green palette.
    static let accentPurple = Color(hex: 0x532C58)
    
    // MARK: - Surfaces & Backgrounds
    
    /// **Surface Light** – Primary background for light mode screens.
    /// Use as: Main app background in light mode, page-level container.
    /// Subtle warm off-white that complements green tones.
    static let surfaceLight = Color(hex: 0xF8F9F7)
    
    /// **Surface Dark** – Primary background for dark mode screens.
    /// Use as: Main app background in dark mode.
    /// Same as wealthDark for unified dark experience.
    static let surfaceDark = wealthDark  // #132A13
    
    /// **Card Light** – Elevated surface for cards in light mode.
    /// Use for: Card backgrounds, modals, input fields in light mode.
    static let cardLight = Color(hex: 0xFFFFFF)
    
    /// **Card Dark** – Elevated surface for cards in dark mode.
    /// Use for: Card backgrounds, modals, input fields in dark mode.
    /// Same as wealthDeep for consistency.
    static let cardDark = wealthDeep  // #31572C
    
    /// **Border Subtle** – Dividers, borders, and separators.
    /// Use for: Hairline dividers, input field borders, subtle separations.
    /// Neutral gray that doesn't compete with content.
    static let borderSubtle = Color(hex: 0xE5E7EB)
    
    // MARK: - Utility Colors
    
    /// **Error Red** – Destructive actions and error states.
    /// Use for: Delete buttons, error banners, validation messages, alerts.
    /// High contrast for accessibility; use sparingly.
    static let errorRed = Color(hex: 0xE74C3C)
    
    /// **Warning Amber** – Warning states and caution indicators.
    /// Use for: Non-critical warnings, pending states, attention indicators.
    static let warningAmber = Color(hex: 0xF39C12)
    
    /// **Success Bright** – Success confirmations (uses wealthBright).
    /// Use for: Success banners, completed states, positive feedback.
    static let successGreen = wealthBright  // #90A955
    
    // MARK: - Text Colors
    
    /// **Text on Light** – Primary text color for light backgrounds.
    /// Use for: Body text, headings, labels on light surfaces.
    /// Same as wealthDark for brand consistency.
    static let textOnLight = wealthDark  // #132A13
    
    /// **Text on Dark** – Primary text color for dark backgrounds.
    /// Use for: Text on dark surfaces (wealthDark, wealthDeep, wealthStrong).
    /// Same as wealthLight for readability.
    static let textOnDark = wealthLight  // #ECF39E
    
    /// **Text Secondary Light** – Secondary text on light backgrounds.
    /// Lower contrast for less important information.
    static let textSecondaryLight = Color(hex: 0x4A5D4A)
    
    /// **Text Secondary Dark** – Secondary text on dark backgrounds.
    static let textSecondaryDark = Color(hex: 0xC4D9A8)
    
    // MARK: - Semantic Aliases (Convenience)
    
    /// Primary brand color - use for main CTAs
    static var primaryBrand: Color { wealthStrong }
    
    /// Primary CTA color - same as primaryBrand
    static var primaryCTA: Color { wealthStrong }
    
    /// Secondary CTA color - use for less prominent actions
    static var secondaryCTA: Color { accentPurple }
    
    /// Alias for errorRed – use for destructive actions
    static var destructive: Color { errorRed }
    
    /// Alias for warningAmber – use for warning states
    static var warning: Color { warningAmber }
    
    /// Alias for successGreen – use for success states
    static var success: Color { successGreen }
    
    // MARK: - Gradient System
    
    /// Canonical brand gradient: Dark → Strong → Bright → Light
    /// Use for: Hero sections, onboarding backgrounds, splash screens
    static let brandGradient = LinearGradient(
        colors: [wealthDark, wealthStrong, wealthBright, wealthLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Light mode gradient: Strong → Bright
    /// Use for: Card backgrounds, section headers in light mode
    static let lightGradient = LinearGradient(
        colors: [wealthStrong, wealthBright],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Dark mode gradient: Dark → Deep
    /// Use for: Backgrounds, navigation bars in dark mode
    static let darkGradient = LinearGradient(
        colors: [wealthDark, wealthDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Accent gradient: Purple → Bright Green
    /// Use for: Special emphasis, premium features, highlights
    static let accentGradient = LinearGradient(
        colors: [accentPurple, wealthBright],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize a Color from a hex integer value.
    /// - Parameter hex: The hex color value (e.g., 0x132A13)
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
    
    /// Initialize a Color from a hex string.
    /// - Parameter hexString: The hex color string (e.g., "#132A13" or "132A13")
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
                    .foregroundColor(ThemeColors.wealthDark)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Core Wealth Greens")
                        .font(.headline)
                        .foregroundColor(ThemeColors.wealthDark)
                    
                    colorRow("wealthDark", ThemeColors.wealthDark)
                    colorRow("wealthDeep", ThemeColors.wealthDeep)
                    colorRow("wealthStrong", ThemeColors.wealthStrong)
                    colorRow("wealthBright", ThemeColors.wealthBright)
                    colorRow("wealthLight", ThemeColors.wealthLight)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Accent & Surfaces")
                        .font(.headline)
                        .foregroundColor(ThemeColors.wealthDark)
                    
                    colorRow("accentPurple", ThemeColors.accentPurple)
                    colorRow("surfaceLight", ThemeColors.surfaceLight)
                    colorRow("cardLight", ThemeColors.cardLight)
                    colorRow("cardDark", ThemeColors.cardDark)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Utility Colors")
                        .font(.headline)
                        .foregroundColor(ThemeColors.wealthDark)
                    
                    colorRow("errorRed", ThemeColors.errorRed)
                    colorRow("warningAmber", ThemeColors.warningAmber)
                    colorRow("successGreen", ThemeColors.successGreen)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gradients")
                        .font(.headline)
                        .foregroundColor(ThemeColors.wealthDark)
                    
                    gradientRow("brandGradient", ThemeColors.brandGradient)
                    gradientRow("lightGradient", ThemeColors.lightGradient)
                    gradientRow("darkGradient", ThemeColors.darkGradient)
                    gradientRow("accentGradient", ThemeColors.accentGradient)
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
