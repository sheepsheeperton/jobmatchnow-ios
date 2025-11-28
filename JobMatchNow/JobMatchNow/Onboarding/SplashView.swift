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
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.15, blue: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App Icon / Logo
                ZStack {
                    Circle()
                        .fill(Theme.primaryBlue.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                    
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.primaryBlue)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                }
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isAnimating)
                
                // App Name
                VStack(spacing: 8) {
                    Text("JobMatchNow")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Find your perfect match")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Loading indicator
                if !checkComplete {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                        .padding(.top, 40)
                }
            }
        }
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

