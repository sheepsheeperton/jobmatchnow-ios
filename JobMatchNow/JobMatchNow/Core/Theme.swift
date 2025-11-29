//
//  Theme.swift
//  JobMatchNow
//
//  ⚠️ DEPRECATION NOTICE:
//  Theme is being phased out as a color source.
//  All new code MUST use ThemeColors.* directly for colors.
//
//  This file now provides:
//  - Spacing tokens (Theme.Spacing)
//  - Corner radius tokens (Theme.CornerRadius)
//  - Button styles (Theme.PrimaryButtonStyle, etc.)
//
//  For the canonical color palette, see:
//  - ThemeColors.swift (Swift color tokens)
//  - Docs/ColorPalette.md (usage documentation)
//

import SwiftUI

// MARK: - JobMatchNow Theme

enum Theme {
    
    // MARK: - Deprecated Color Aliases
    // ⚠️ These exist only for backward compatibility.
    // All usages have been migrated to ThemeColors.* as of Nov 2024.
    // These will be REMOVED in a future version.
    
    /// @available(*, deprecated, message: "Use ThemeColors.primaryBrand instead")
    @available(*, deprecated, message: "Use ThemeColors.primaryBrand instead")
    static let primaryBrand = ThemeColors.primaryBrand
    
    /// @available(*, deprecated, message: "Use ThemeColors.primaryComplement instead")
    @available(*, deprecated, message: "Use ThemeColors.primaryComplement instead")
    static let primaryBlue = ThemeColors.primaryComplement
    
    /// @available(*, deprecated, message: "Use ThemeColors tokens instead")
    @available(*, deprecated, message: "Use ThemeColors tokens instead")
    static let primary = Color("AccentColor")
    
    /// @available(*, deprecated, message: "Use Color.secondary or ThemeColors.textOnLight instead")
    @available(*, deprecated, message: "Use Color.secondary or ThemeColors.textOnLight instead")
    static let secondaryText = Color.secondary
    
    /// @available(*, deprecated, message: "Use ThemeColors.surfaceLight or surfaceWhite instead")
    @available(*, deprecated, message: "Use ThemeColors.surfaceLight or surfaceWhite instead")
    static let background = Color(UIColor.systemBackground)
    
    /// @available(*, deprecated, message: "Use ThemeColors.surfaceWhite instead")
    @available(*, deprecated, message: "Use ThemeColors.surfaceWhite instead")
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    
    /// @available(*, deprecated, message: "Use ThemeColors.surfaceLight instead")
    @available(*, deprecated, message: "Use ThemeColors.surfaceLight instead")
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    /// @available(*, deprecated, message: "Use ThemeColors.primaryComplement for success states")
    @available(*, deprecated, message: "Use ThemeColors.primaryComplement for success states")
    static let success = Color.green
    
    /// @available(*, deprecated, message: "Use ThemeColors.warmAccent instead")
    @available(*, deprecated, message: "Use ThemeColors.warmAccent instead")
    static let warning = ThemeColors.warmAccent
    
    /// @available(*, deprecated, message: "Use ThemeColors.errorRed instead")
    @available(*, deprecated, message: "Use ThemeColors.errorRed instead")
    static let error = ThemeColors.errorRed
    
    /// @available(*, deprecated, message: "Use ThemeColors.primaryComplement instead")
    @available(*, deprecated, message: "Use ThemeColors.primaryComplement instead")
    static let directCategory = ThemeColors.primaryComplement
    
    /// @available(*, deprecated, message: "Use Color.purple or a custom ThemeColors token")
    @available(*, deprecated, message: "Use Color.purple or a custom ThemeColors token")
    static let adjacentCategory = Color.purple
    
    // MARK: - Gradients
    
    /// Primary brand gradient using Atomic Tangerine
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [ThemeColors.primaryBrand, ThemeColors.primaryBrand.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Blue accent gradient for secondary elements
    static var blueGradient: LinearGradient {
        LinearGradient(
            colors: [ThemeColors.primaryComplement, ThemeColors.deepComplement],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Dark gradient for onboarding and auth screens
    static var onboardingGradient: LinearGradient {
        LinearGradient(
            colors: [
                ThemeColors.midnight,
                ThemeColors.deepComplement.opacity(0.8)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let pill: CGFloat = 24
    }
    
    // MARK: - Button Styles
    
    /// Primary CTA button style using brand orange
    struct PrimaryButtonStyle: ButtonStyle {
        var isDisabled: Bool = false
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(ThemeColors.textOnDark)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isDisabled ? ThemeColors.borderSubtle : ThemeColors.primaryBrand)
                .cornerRadius(CornerRadius.medium)
                .opacity(configuration.isPressed ? 0.9 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
    /// Secondary button style using blue accent
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(ThemeColors.primaryComplement)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(ThemeColors.softComplement.opacity(0.3))
                .cornerRadius(CornerRadius.medium)
                .opacity(configuration.isPressed ? 0.7 : 1.0)
        }
    }
    
    /// Destructive button style for dangerous actions
    struct DestructiveButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(ThemeColors.textOnDark)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(ThemeColors.errorRed)
                .cornerRadius(CornerRadius.medium)
                .opacity(configuration.isPressed ? 0.9 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
}

// MARK: - View Extensions

extension View {
    func primaryButtonStyle(isDisabled: Bool = false) -> some View {
        self.buttonStyle(Theme.PrimaryButtonStyle(isDisabled: isDisabled))
    }
    
    func secondaryButtonStyle() -> some View {
        self.buttonStyle(Theme.SecondaryButtonStyle())
    }
    
    func destructiveButtonStyle() -> some View {
        self.buttonStyle(Theme.DestructiveButtonStyle())
    }
}
