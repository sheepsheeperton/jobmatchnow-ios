//
//  Theme.swift
//  JobMatchNow
//
//  UPDATED: Now references ThemeColors for canonical color values.
//  This file provides backwards-compatible aliases and additional design tokens
//  (spacing, corner radius, button styles) that complement ThemeColors.
//
//  For the canonical color palette, see: ThemeColors.swift and Docs/ColorPalette.md
//

import SwiftUI

// MARK: - JobMatchNow Brand Theme

enum Theme {
    
    // MARK: - Color Aliases (Backwards Compatibility)
    // These reference ThemeColors for the canonical values.
    // New code should prefer using ThemeColors directly.
    
    /// Primary brand color - Atomic Tangerine for CTAs and primary buttons
    /// Prefer: ThemeColors.primaryBrand
    static let primaryBrand = ThemeColors.primaryBrand
    
    /// Primary blue accent - Vibrant Sky Blue for secondary actions
    /// Legacy alias kept for existing code; prefer ThemeColors.primaryComplement
    static let primaryBlue = ThemeColors.primaryComplement
    
    /// Accent color from asset catalog (may differ per platform)
    static let primary = Color("AccentColor")
    
    /// Secondary text color
    static let secondaryText = Color.secondary
    
    // MARK: - Background Colors
    
    /// Light mode background - prefer ThemeColors.surfaceLight for explicit control
    static let background = Color(UIColor.systemBackground)
    
    /// Card/elevated background - prefer ThemeColors.surfaceWhite
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    
    /// Tertiary background layer
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    // MARK: - Semantic Colors
    
    /// Success color for completed states
    static let success = Color.green
    
    /// Warning/caution color - prefer ThemeColors.warmAccent for brand consistency
    static let warning = ThemeColors.warmAccent
    
    /// Error color - prefer ThemeColors.errorRed for brand consistency
    static let error = ThemeColors.errorRed
    
    // MARK: - Category Colors (Job Matching)
    
    /// "Direct" job matches - using primaryComplement for brand alignment
    static let directCategory = ThemeColors.primaryComplement
    
    /// "Adjacent" job matches - keeping purple for differentiation
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
