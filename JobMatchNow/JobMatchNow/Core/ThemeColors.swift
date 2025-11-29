//
//  ThemeColors.swift
//  JobMatchNow
//
//  CANONICAL COLOR PALETTE
//  =======================
//  This file defines the official JobMatchNow brand color palette.
//  All new SwiftUI views should consume colors via ThemeColors rather than
//  hard-coded hex values or system colors.
//
//  Usage: ThemeColors.primaryBrand, ThemeColors.midnight, etc.
//
//  For design rationale and usage guidelines, see: Docs/ColorPalette.md
//

import SwiftUI

// MARK: - ThemeColors Namespace

/// Canonical JobMatchNow color palette.
/// Use these tokens for all UI elements to ensure brand consistency.
enum ThemeColors {
    
    // MARK: - Brand / CTA
    
    /// **Atomic Tangerine** – Main brand color for primary buttons and hero CTAs.
    /// Use for high-importance actions like "Upload Résumé", "Create Account", "View Jobs".
    /// Works on both light and dark backgrounds with white text.
    static let primaryBrand = Color(hex: 0xFF7538)
    
    // MARK: - Complementary Blues
    
    /// **Vibrant Sky Blue** – Secondary CTAs, highlights, and interactive elements.
    /// Use for secondary buttons, links, selected states, and accent borders.
    /// Pairs well with primaryBrand for visual hierarchy.
    static let primaryComplement = Color(hex: 0x38A1FF)
    
    /// **Soft Ice Blue** – Subtle card tints, onboarding illustrations, and backgrounds.
    /// Use for light blue backgrounds, illustration fills, and gentle emphasis areas.
    /// Low contrast; never use for text or small elements.
    static let softComplement = Color(hex: 0xA1D6FF)
    
    /// **Deep Cyan** – Dark-mode card backgrounds, navigation bars, and overlays.
    /// Use for elevated surfaces in dark mode, modal backgrounds, and nav elements.
    /// Pairs with textOnDark for readable text.
    static let deepComplement = Color(hex: 0x005D8A)
    
    /// **Midnight Navy** – Headings, primary text on light, dark-mode surfaces.
    /// Use for all body text and headings on light backgrounds.
    /// Also serves as the primary dark-mode surface color.
    static let midnight = Color(hex: 0x0D3A6A)
    
    // MARK: - Warm Accent
    
    /// **Warm Honey** – Warnings, subtle highlights, and chart accents.
    /// Use for warning states (not errors), badges, progress indicators, and data viz.
    /// Warmer alternative to primaryBrand for secondary emphasis.
    static let warmAccent = Color(hex: 0xFFB140)
    
    // MARK: - Neutrals
    
    /// **Light Gray Surface** – Primary background for light mode screens.
    /// Use as the main app background in light mode.
    /// Provides subtle contrast against white cards.
    static let surfaceLight = Color(hex: 0xF9F9F9)
    
    /// **Pure White** – Card backgrounds and elevated surfaces in light mode.
    /// Use for cards, modals, and content containers that sit above surfaceLight.
    static let surfaceWhite = Color(hex: 0xFFFFFF)
    
    /// **Subtle Border Gray** – Dividers, borders, and separators.
    /// Use for hairline dividers, input field borders, and subtle separations.
    /// Low visual weight; doesn't compete with content.
    static let borderSubtle = Color(hex: 0xE5E7EB)
    
    // MARK: - Utility
    
    /// **Error Red** – Destructive actions and error states.
    /// Use for delete buttons, error banners, validation messages, and alerts.
    /// High contrast for accessibility; use sparingly.
    static let errorRed = Color(hex: 0xE74C3C)
    
    /// **Text on Light** – Primary text color for light backgrounds.
    /// Same as midnight; use for body text, headings, and labels on light surfaces.
    static let textOnLight = Color(hex: 0x0D3A6A)
    
    /// **Text on Dark** – Primary text color for dark backgrounds.
    /// Use for all text on dark surfaces (midnight, deepComplement, etc.).
    static let textOnDark = Color(hex: 0xF9F9F9)
    
    // MARK: - Semantic Aliases (Convenience)
    
    /// Alias for primaryBrand – use for main CTA buttons
    static var cta: Color { primaryBrand }
    
    /// Alias for errorRed – use for destructive actions
    static var destructive: Color { errorRed }
    
    /// Alias for warmAccent – use for warning states
    static var warning: Color { warmAccent }
    
    /// Alias for softComplement with reduced opacity – use for subtle backgrounds
    static var subtleHighlight: Color { softComplement.opacity(0.3) }
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize a Color from a hex integer value.
    /// - Parameter hex: The hex color value (e.g., 0xFF7538)
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
    
    /// Initialize a Color from a hex string.
    /// - Parameter hexString: The hex color string (e.g., "#FF7538" or "FF7538")
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
            VStack(alignment: .leading, spacing: 16) {
                Text("JobMatchNow Color Palette")
                    .font(.largeTitle.bold())
                    .foregroundColor(ThemeColors.midnight)
                
                Group {
                    colorRow("primaryBrand", ThemeColors.primaryBrand)
                    colorRow("primaryComplement", ThemeColors.primaryComplement)
                    colorRow("softComplement", ThemeColors.softComplement)
                    colorRow("deepComplement", ThemeColors.deepComplement)
                    colorRow("midnight", ThemeColors.midnight)
                }
                
                Group {
                    colorRow("warmAccent", ThemeColors.warmAccent)
                    colorRow("surfaceLight", ThemeColors.surfaceLight)
                    colorRow("surfaceWhite", ThemeColors.surfaceWhite)
                    colorRow("borderSubtle", ThemeColors.borderSubtle)
                    colorRow("errorRed", ThemeColors.errorRed)
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
}

#Preview {
    ThemeColorsPreview()
}
#endif

