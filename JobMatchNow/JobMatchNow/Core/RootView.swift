import SwiftUI

// MARK: - Root View

/// Root view that manages app flow based on authentication state
struct RootView: View {
    @StateObject private var appState = AppState.shared
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            switch appState.authState {
            case .loading:
                SplashView()
                
            case .unauthenticated:
                if !appState.hasCompletedOnboarding {
                    OnboardingCarouselView {
                        // After onboarding, show auth
                        showOnboarding = false
                    }
                } else {
                    AuthView()
                }
                
            case .authenticated:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.authState)
    }
}

#Preview {
    RootView()
}

