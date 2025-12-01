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
    
    // MARK: - Gradients (Updated for Green Wealth System)
    
    /// Primary brand gradient using wealth greens
    static var primaryGradient: LinearGradient {
        ThemeColors.brandGradient
    }
    
    /// Light gradient for cards and sections
    static var lightGradient: LinearGradient {
        ThemeColors.lightGradient
    }
    
    /// Dark gradient for onboarding and auth screens
    static var onboardingGradient: LinearGradient {
        ThemeColors.darkGradient
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
    
    /// Primary CTA button style using wealth green
    struct PrimaryButtonStyle: ButtonStyle {
        var isDisabled: Bool = false
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(ThemeColors.textOnDark)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isDisabled ? ThemeColors.borderSubtle : ThemeColors.primaryCTA)
                .cornerRadius(CornerRadius.medium)
                .opacity(configuration.isPressed ? 0.9 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
    /// Secondary button style using accent purple
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(ThemeColors.textOnDark)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(ThemeColors.secondaryCTA)
                .cornerRadius(CornerRadius.medium)
                .opacity(configuration.isPressed ? 0.9 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
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
