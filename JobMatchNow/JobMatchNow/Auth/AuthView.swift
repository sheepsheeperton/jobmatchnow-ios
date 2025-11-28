import SwiftUI

// MARK: - Auth View

/// Authentication screen with OAuth provider buttons
struct AuthView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var appState = AppState.shared
    @State private var showEmailForm = false
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.08, green: 0.12, blue: 0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        // Logo
                        ZStack {
                            Circle()
                                .fill(Theme.primaryBlue.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 44))
                                .foregroundColor(Theme.primaryBlue)
                        }
                        
                        Text("Welcome to JobMatchNow")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Sign in to start finding your perfect job match")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                    
                    // OAuth Buttons
                    VStack(spacing: 16) {
                        // Google
                        Button(action: {
                            Task {
                                try? await authManager.signInWithGoogle()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .font(.title2)
                                Text("Continue with Google")
                                    .font(.headline)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .cornerRadius(Theme.CornerRadius.medium)
                        }
                        
                        // LinkedIn
                        Button(action: {
                            Task {
                                try? await authManager.signInWithLinkedIn()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "link.circle.fill")
                                    .font(.title2)
                                Text("Continue with LinkedIn")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.0, green: 0.47, blue: 0.71)) // LinkedIn blue
                            .cornerRadius(Theme.CornerRadius.medium)
                        }
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                            Text("or")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 8)
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 8)
                        
                        #if DEBUG
                        // Demo mode for testing
                        Button(action: {
                            // Skip auth for testing
                            AppState.shared.signIn(user: AppState.UserInfo(
                                id: "demo_user",
                                email: "demo@jobmatchnow.ai",
                                providers: ["demo"]
                            ))
                        }) {
                            Text("Skip for Demo")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 8)
                        #endif
                        
                        // Email option
                        Button(action: {
                            withAnimation {
                                showEmailForm.toggle()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .font(.title2)
                                Text("Continue with Email")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(Theme.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Email form (expandable)
                        if showEmailForm {
                            VStack(spacing: 16) {
                                TextField("Email", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(Theme.CornerRadius.small)
                                    .foregroundColor(.white)
                                
                                SecureField("Password", text: $password)
                                    .textContentType(.password)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(Theme.CornerRadius.small)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    Task {
                                        try? await authManager.signInWithEmail(email: email, password: password)
                                    }
                                }) {
                                    Text("Sign In")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Theme.primaryBlue)
                                        .cornerRadius(Theme.CornerRadius.small)
                                }
                                .disabled(email.isEmpty || password.isEmpty)
                            }
                            .padding(.top, 8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Error message
                    if let error = authManager.error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Terms and Privacy
                    VStack(spacing: 8) {
                        Text("By continuing, you agree to our")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                        
                        HStack(spacing: 4) {
                            Button("Terms of Service") {
                                // Open terms
                            }
                            .font(.caption)
                            .foregroundColor(Theme.primaryBlue)
                            
                            Text("and")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            
                            Button("Privacy Policy") {
                                // Open privacy
                            }
                            .font(.caption)
                            .foregroundColor(Theme.primaryBlue)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            
            // Loading overlay
            if authManager.isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Signing in...")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    AuthView()
}

