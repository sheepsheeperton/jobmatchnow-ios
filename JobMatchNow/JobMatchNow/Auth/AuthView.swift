import SwiftUI
import AuthenticationServices

// MARK: - Auth Mode

enum AuthMode {
    case signIn
    case signUp
}

// MARK: - Auth View

/// Authentication screen with OAuth provider buttons
struct AuthView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var appState = AppState.shared
    @State private var showEmailForm = false
    @State private var authMode: AuthMode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
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
                        // Sign in with Apple
                        SignInWithAppleButton(.signIn) { request in
                            let appleRequest = authManager.startSignInWithApple()
                            request.requestedScopes = appleRequest.requestedScopes
                            request.nonce = appleRequest.nonce
                        } onCompletion: { result in
                            Task {
                                await authManager.handleAppleSignIn(result: result)
                            }
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 56)
                        .cornerRadius(Theme.CornerRadius.medium)
                        
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
                            .background(Color(red: 0.0, green: 0.47, blue: 0.71))
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
                            emailFormView
                        }
                        
                        #if DEBUG
                        // Demo mode for testing
                        Button(action: {
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
                    }
                    .padding(.horizontal, 24)
                    
                    // Error message
                    if let error = authManager.error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                            .multilineTextAlignment(.center)
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
                    
                    Text(authMode == .signIn ? "Signing in..." : "Creating account...")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Email Form View
    
    private var emailFormView: some View {
        VStack(spacing: 16) {
            // Mode toggle
            Picker("Mode", selection: $authMode) {
                Text("Sign In").tag(AuthMode.signIn)
                Text("Sign Up").tag(AuthMode.signUp)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 8)
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(Theme.CornerRadius.small)
                .foregroundColor(.white)
            
            SecureField("Password", text: $password)
                .textContentType(authMode == .signUp ? .newPassword : .password)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(Theme.CornerRadius.small)
                .foregroundColor(.white)
            
            // Confirm password for sign up
            if authMode == .signUp {
                SecureField("Confirm Password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.small)
                    .foregroundColor(.white)
                
                Text("Password must be at least 6 characters")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Submit button
            Button(action: submitEmailForm) {
                Text(authMode == .signIn ? "Sign In" : "Create Account")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isFormValid ? Theme.primaryBlue : Color.gray)
                    .cornerRadius(Theme.CornerRadius.small)
            }
            .disabled(!isFormValid)
            
            // Switch mode text
            Button(action: {
                withAnimation {
                    authMode = authMode == .signIn ? .signUp : .signIn
                    confirmPassword = ""
                }
            }) {
                Text(authMode == .signIn ? "Don't have an account? Sign up" : "Already have an account? Sign in")
                    .font(.caption)
                    .foregroundColor(Theme.primaryBlue)
            }
            .padding(.top, 4)
        }
        .padding(.top, 8)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // MARK: - Form Validation
    
    private var isFormValid: Bool {
        let emailValid = !email.isEmpty && email.contains("@")
        let passwordValid = password.count >= 6
        
        if authMode == .signUp {
            return emailValid && passwordValid && password == confirmPassword
        }
        return emailValid && passwordValid
    }
    
    // MARK: - Submit Form
    
    private func submitEmailForm() {
        Task {
            do {
                if authMode == .signIn {
                    try await authManager.signInWithEmail(email: email, password: password)
                } else {
                    try await authManager.signUpWithEmail(email: email, password: password)
                }
            } catch {
                // Error is handled by authManager
            }
        }
    }
}

#Preview {
    AuthView()
}
