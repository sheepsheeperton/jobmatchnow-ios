import SwiftUI

// MARK: - Splash View

/// Initial splash screen shown on app launch
/// Uses dark hero gradient with accent glow for premium feel
struct SplashView: View {
    @StateObject private var appState = AppState.shared
    @State private var isAnimating = false
    @State private var checkComplete = false
    
    var body: some View {
        ZStack {
            // Background - rich dark gradient
            ThemeColors.heroGradientDark
                .ignoresSafeArea()
            
            // Subtle accent glow behind logo
            ThemeColors.accentGlow
                .frame(width: 300, height: 300)
                .offset(y: -40)
            
            VStack(spacing: 24) {
                // App Icon / Logo
                ZStack {
                    Circle()
                        .fill(ThemeColors.primaryAccent.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                    
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 50))
                        .foregroundColor(ThemeColors.primaryAccent)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                }
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isAnimating)
                
                // App Name
                VStack(spacing: 8) {
                    Text("JobMatchNow")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeColors.textOnDark)
                    
                    Text("Find your perfect match")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.textOnDark.opacity(0.7))
                }
                
                // Loading indicator
                if !checkComplete {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: ThemeColors.primaryAccent))
                        .scaleEffect(1.2)
                        .padding(.top, 40)
                }
            }
        }
        .statusBarLightContent()
        .onAppear {
            isAnimating = true
            checkSession()
        }
    }
    
    private func checkSession() {
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            let hasSession = await AuthManager.shared.checkExistingSession()
            
            await MainActor.run {
                checkComplete = true
                
                if hasSession {
                    appState.authState = .authenticated
                } else {
                    appState.authState = .unauthenticated
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
