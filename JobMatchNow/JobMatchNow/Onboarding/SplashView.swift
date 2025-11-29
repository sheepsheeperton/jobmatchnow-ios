import SwiftUI

// MARK: - Splash View

/// Initial splash screen shown on app launch
/// Checks for existing Supabase session and routes accordingly
struct SplashView: View {
    @StateObject private var appState = AppState.shared
    @State private var isAnimating = false
    @State private var checkComplete = false
    
    var body: some View {
        ZStack {
            // Background gradient - midnight theme
            LinearGradient(
                colors: [
                    ThemeColors.midnight,
                    ThemeColors.deepComplement
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App Icon / Logo - brand orange for identity
                ZStack {
                    Circle()
                        .fill(ThemeColors.primaryBrand.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                    
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 50))
                        .foregroundColor(ThemeColors.primaryBrand)
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
                        .progressViewStyle(CircularProgressViewStyle(tint: ThemeColors.textOnDark))
                        .scaleEffect(1.2)
                        .padding(.top, 40)
                }
            }
        }
        .statusBarLightContent()  // Dark background → light status bar
        .onAppear {
            isAnimating = true
            checkSession()
        }
    }
    
    private func checkSession() {
        Task {
            // Small delay for branding visibility
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            // Check for existing session
            let hasSession = await AuthManager.shared.checkExistingSession()
            
            await MainActor.run {
                checkComplete = true
                
                if hasSession {
                    // User is authenticated, go to main app
                    appState.authState = .authenticated
                } else {
                    // No session, show onboarding or auth
                    appState.authState = .unauthenticated
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
