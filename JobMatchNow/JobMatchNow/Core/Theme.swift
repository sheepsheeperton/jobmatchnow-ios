import SwiftUI

// MARK: - JobMatchNow Brand Theme

enum Theme {
    // MARK: - Brand Colors
    
    /// Primary brand color - used for CTAs, buttons, and accents
    static let primary = Color("AccentColor")
    
    /// Fallback primary color if AccentColor isn't set
    static let primaryBlue = Color(red: 0.0, green: 0.478, blue: 1.0) // #007AFF
    
    /// Secondary text color
    static let secondaryText = Color.secondary
    
    /// Background colors
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    /// Success color for completed states
    static let success = Color.green
    
    /// Warning/caution color
    static let warning = Color.orange
    
    /// Error color
    static let error = Color.red
    
    // MARK: - Category Colors
    
    static let directCategory = Color.blue
    static let adjacentCategory = Color.purple
    
    // MARK: - Gradients
    
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryBlue, primaryBlue.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var onboardingGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.1, blue: 0.2),
                Color(red: 0.05, green: 0.15, blue: 0.3)
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
    
    struct PrimaryButtonStyle: ButtonStyle {
        var isDisabled: Bool = false
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isDisabled ? Color.gray : Theme.primaryBlue)
                .cornerRadius(CornerRadius.medium)
                .opacity(configuration.isPressed ? 0.9 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(Theme.primaryBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Theme.primaryBlue.opacity(0.1))
                .cornerRadius(CornerRadius.medium)
                .opacity(configuration.isPressed ? 0.7 : 1.0)
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
}

