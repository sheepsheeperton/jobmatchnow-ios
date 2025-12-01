//
//  ThemeColors.swift
//  JobMatchNow
//
//  CANONICAL COLOR PALETTE - PALETTE A (INK + INDIGO SYSTEM)
//  ==========================================================
//  This file defines the official JobMatchNow brand color palette.
//  Built around cool purples/indigos for trust, clarity, and modern calm.
//  
//  All SwiftUI views should consume colors via ThemeColors rather than
//  hard-coded hex values or system colors.
//
//  Usage: ThemeColors.deepIndigo, ThemeColors.primaryBrand, etc.
//
//  For design rationale and usage guidelines, see: Docs/ColorPalette.md
//

import SwiftUI

// MARK: - ThemeColors Namespace

/// Canonical JobMatchNow color palette.
/// Palette A: Cool indigo-violet system for trust, clarity, and premium feel.
/// Use these tokens for all UI elements to ensure brand consistency.
enum ThemeColors {
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Core Palette Colors
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Ink Black** – Near-black with subtle teal undertone.
    /// Use for: Dark mode backgrounds, primary text on light surfaces, high-contrast anchors.
    /// This is our "text black" and deepest surface color.
    static let inkBlack = Color(hex: 0x000505)
    
    /// **Deep Indigo** – Primary brand color, rich purple-blue.
    /// Use for: Primary CTA buttons, key accent elements, active states.
    /// This is the hero brand color that drives action.
    static let deepIndigo = Color(hex: 0x3B3355)
    
    /// **Slate Violet** – Muted purple-grey for secondary elements.
    /// Use for: Secondary CTAs, selected chips, tab highlights, supporting UI.
    /// Provides visual interest without competing with primary actions.
    static let slateViolet = Color(hex: 0x5D5D81)
    
    /// **Mist Blue** – Soft, calm blue-grey for subtle backgrounds.
    /// Use for: Soft backgrounds, badges, subtle highlights, illustration fills.
    /// Creates visual breathing room and gentle emphasis.
    static let mistBlue = Color(hex: 0xBFCDE0)
    
    /// **Paper White** – Warm off-white for light surfaces.
    /// Use for: Light mode backgrounds, cards, modal surfaces.
    /// Softer than pure white for reduced eye strain.
    static let paperWhite = Color(hex: 0xFEFCFD)
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Supporting Neutrals
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Soft Grey** – Secondary text on light backgrounds.
    /// Use for: Captions, timestamps, less prominent metadata.
    static let softGrey = Color(hex: 0x6B7280)
    
    /// **Border Grey** – Light borders that work on paper/mist surfaces.
    /// Use for: Dividers, input borders, card outlines.
    static let borderGrey = Color(hex: 0xD1D5DB)
    
    /// **Surface Grey Dark** – Elevated dark surfaces (cards in dark mode).
    /// Use for: Dark mode card backgrounds, modals in dark mode.
    /// Slightly lighter than inkBlack for visual hierarchy.
    static let surfaceGreyDark = Color(hex: 0x1A1B26)
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Semantic Brand Tokens
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// Primary brand color – use for main CTAs.
    /// Maps to: deepIndigo
    static var primaryBrand: Color { deepIndigo }
    
    /// Primary CTA color – same as primaryBrand.
    static var primaryCTA: Color { deepIndigo }
    
    /// Primary complement – use for secondary CTAs, selections.
    /// Maps to: slateViolet
    static var primaryComplement: Color { slateViolet }
    
    /// Secondary CTA color – same as primaryComplement.
    static var secondaryCTA: Color { slateViolet }
    
    /// Soft complement – use for subtle backgrounds, soft highlights.
    /// Maps to: mistBlue
    static var softComplement: Color { mistBlue }
    
    /// Deep complement – use for dark mode cards, deep backgrounds.
    /// Maps to: inkBlack
    static var deepComplement: Color { inkBlack }
    
    /// Midnight – deep dark color for dark mode shells.
    /// Maps to: inkBlack (unified dark experience)
    static var midnight: Color { inkBlack }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Surfaces & Backgrounds
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Surface Light** – Primary background for light mode screens.
    /// Maps to: paperWhite
    static let surfaceLight = paperWhite
    
    /// **Surface Dark** – Primary background for dark mode screens.
    /// Maps to: inkBlack
    static let surfaceDark = inkBlack
    
    /// **Card Light** – Elevated surface for cards in light mode.
    /// Maps to: paperWhite (pure white also acceptable)
    static let cardLight = paperWhite
    
    /// **Card Dark** – Elevated surface for cards in dark mode.
    /// Maps to: surfaceGreyDark
    static let cardDark = surfaceGreyDark
    
    /// **Border Subtle** – Dividers, borders, and separators.
    /// Maps to: borderGrey
    static let borderSubtle = borderGrey
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Text Colors
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Text on Light** – Primary text color for light backgrounds.
    /// Maps to: deepIndigo (slightly softened black for brand cohesion)
    static let textOnLight = deepIndigo
    
    /// **Text on Dark** – Primary text color for dark backgrounds.
    /// Maps to: paperWhite (near-white for maximum contrast)
    static let textOnDark = paperWhite
    
    /// **Text Secondary Light** – Secondary text on light backgrounds.
    /// Maps to: softGrey
    static let textSecondaryLight = softGrey
    
    /// **Text Secondary Dark** – Secondary text on dark backgrounds.
    /// Maps to: mistBlue
    static let textSecondaryDark = mistBlue
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Utility / Status Colors
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Error Red** – Destructive actions and error states.
    /// Use for: Delete buttons, error banners, validation messages.
    static let errorRed = Color(hex: 0xE74C3C)
    
    /// **Warning Amber** – Warning states and caution indicators.
    /// Use for: Non-critical warnings, pending states, attention notices.
    /// Reserved for status only, NOT brand usage.
    static let warningAmber = Color(hex: 0xF39C12)
    
    /// **Success Green** – Success confirmations and positive states.
    /// Use for: Success banners, completed states, positive feedback.
    static let successGreen = Color(hex: 0x27AE60)
    
    /// **Info Teal** – Informational states and neutral highlights.
    /// Use for: Info banners, tips, neutral callouts.
    static let infoTeal = Color(hex: 0x17A2B8)
    
    // MARK: Semantic Aliases for Status
    
    static var destructive: Color { errorRed }
    static var warning: Color { warningAmber }
    static var success: Color { successGreen }
    static var info: Color { infoTeal }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Legacy Compatibility Aliases
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // These aliases maintain backward compatibility with existing code.
    // They map old green palette names to new Palette A equivalents.
    
    /// Legacy: wealthDark → inkBlack
    static var wealthDark: Color { inkBlack }
    
    /// Legacy: wealthDeep → surfaceGreyDark
    static var wealthDeep: Color { surfaceGreyDark }
    
    /// Legacy: wealthStrong → deepIndigo
    static var wealthStrong: Color { deepIndigo }
    
    /// Legacy: wealthBright → slateViolet
    static var wealthBright: Color { slateViolet }
    
    /// Legacy: wealthLight → mistBlue
    static var wealthLight: Color { mistBlue }
    
    /// Legacy: accentPurple → slateViolet (now primary in palette)
    static var accentPurple: Color { slateViolet }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Gradient System
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /// **Brand Hero Gradient (Light)** – Full palette sweep for hero sections.
    /// Use for: Splash screens, onboarding backgrounds, marketing heroes.
    /// Direction: Top-leading to bottom-trailing (diagonal)
    static let brandGradient = LinearGradient(
        colors: [inkBlack, deepIndigo, slateViolet, mistBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// **Light Gradient** – Soft gradient for light mode emphasis.
    /// Use for: Card headers, section backgrounds in light mode.
    static let lightGradient = LinearGradient(
        colors: [slateViolet, mistBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// **Dark Gradient** – Deep gradient for dark mode backgrounds.
    /// Use for: Dark mode shells, splash screens, navigation bars.
    static let darkGradient = LinearGradient(
        colors: [inkBlack, deepIndigo],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// **Hero Gradient (Dark Mode)** – Simpler, more subtle for dark contexts.
    /// Use for: Dark mode hero sections, modals with emphasis.
    static let heroGradientDark = LinearGradient(
        colors: [inkBlack, deepIndigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// **Accent Gradient** – Violet-to-mist for special emphasis.
    /// Use for: Premium features, special badges, highlights.
    static let accentGradient = LinearGradient(
        colors: [slateViolet, mistBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize a Color from a hex integer value.
    /// - Parameter hex: The hex color value (e.g., 0x3B3355)
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
    
    /// Initialize a Color from a hex string.
    /// - Parameter hexString: The hex color string (e.g., "#3B3355" or "3B3355")
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
                
                // Core Palette
                VStack(alignment: .leading, spacing: 16) {
                    Text("Core Palette")
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnLight)
                    
                    colorRow("inkBlack", ThemeColors.inkBlack)
                    colorRow("deepIndigo", ThemeColors.deepIndigo)
                    colorRow("slateViolet", ThemeColors.slateViolet)
                    colorRow("mistBlue", ThemeColors.mistBlue)
                    colorRow("paperWhite", ThemeColors.paperWhite)
                }
                
                // Supporting Neutrals
                VStack(alignment: .leading, spacing: 16) {
                    Text("Supporting Neutrals")
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnLight)
                    
                    colorRow("softGrey", ThemeColors.softGrey)
                    colorRow("borderGrey", ThemeColors.borderGrey)
                    colorRow("surfaceGreyDark", ThemeColors.surfaceGreyDark)
                }
                
                // Semantic Tokens
                VStack(alignment: .leading, spacing: 16) {
                    Text("Semantic Tokens")
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnLight)
                    
                    colorRow("primaryBrand", ThemeColors.primaryBrand)
                    colorRow("secondaryCTA", ThemeColors.secondaryCTA)
                    colorRow("surfaceLight", ThemeColors.surfaceLight)
                    colorRow("cardLight", ThemeColors.cardLight)
                }
                
                // Utility Colors
                VStack(alignment: .leading, spacing: 16) {
                    Text("Utility Colors")
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnLight)
                    
                    colorRow("errorRed", ThemeColors.errorRed)
                    colorRow("warningAmber", ThemeColors.warningAmber)
                    colorRow("successGreen", ThemeColors.successGreen)
                    colorRow("infoTeal", ThemeColors.infoTeal)
                }
                
                // Gradients
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gradients")
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnLight)
                    
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
