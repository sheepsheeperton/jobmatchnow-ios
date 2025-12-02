import SwiftUI

// MARK: - Auth Mode

enum AuthMode {
    case signIn
    case signUp
}

// MARK: - Auth View

/// Authentication screen (Palette A colors only, no halos)
struct AuthView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var appState = AppState.shared
    @State private var authMode: AuthMode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSubmitting = false
    @State private var alertMessage: String?
    @State private var showAlert = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword
    }
    
    var body: some View {
        ZStack {
            // Soft background gradient (Palette A)
            ThemeColors.introGradient
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Logo - simple, no halo
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ThemeColors.primaryAccent)
                    .padding(.bottom, 20)
                
                Text("Welcome to JobMatchNow")
                    .font(.title2.bold())
                    .foregroundColor(ThemeColors.textOnDark)
                
                // Mode toggle
                Picker("Mode", selection: $authMode) {
                    Text("Sign In").tag(AuthMode.signIn)
                    Text("Sign Up").tag(AuthMode.signUp)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 40)
                .onChange(of: authMode) { _, _ in
                    confirmPassword = ""
                }
                
                // Email
                TextField("Email", text: $email)
                    .focused($focusedField, equals: .email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(ThemeColors.textOnDark.opacity(0.15))
                    .cornerRadius(10)
                    .foregroundColor(ThemeColors.textOnDark)
                    .frame(height: 50)
                    .padding(.horizontal, 40)
                
                // Password
                SecureField("Password", text: $password)
                    .focused($focusedField, equals: .password)
                    .padding()
                    .background(ThemeColors.textOnDark.opacity(0.15))
                    .cornerRadius(10)
                    .foregroundColor(ThemeColors.textOnDark)
                    .frame(height: 50)
                    .padding(.horizontal, 40)
                
                // Confirm Password (Sign Up only)
                if authMode == .signUp {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .focused($focusedField, equals: .confirmPassword)
                        .padding()
                        .background(ThemeColors.textOnDark.opacity(0.15))
                        .cornerRadius(10)
                        .foregroundColor(ThemeColors.textOnDark)
                        .frame(height: 50)
                        .padding(.horizontal, 40)
                }
                
                // Submit button - primaryAccent (Palette A purple)
                Button {
                    submitForm()
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: ThemeColors.textOnDark))
                    } else {
                        Text(authMode == .signIn ? "Sign In" : "Create Account")
                            .font(.headline)
                            .foregroundColor(ThemeColors.textOnDark)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(canSubmit ? ThemeColors.primaryAccent : ThemeColors.slateViolet.opacity(0.5))
                .cornerRadius(10)
                .padding(.horizontal, 40)
                .disabled(!canSubmit)
                
                // Divider
                HStack {
                    Rectangle().fill(ThemeColors.textOnDark.opacity(0.3)).frame(height: 1)
                    Text("or").foregroundColor(ThemeColors.textOnDark.opacity(0.5))
                    Rectangle().fill(ThemeColors.textOnDark.opacity(0.3)).frame(height: 1)
                }
                .padding(.horizontal, 40)
                
                // LinkedIn - slateViolet
                Button {
                    Task {
                        try? await authManager.signInWithLinkedIn()
                    }
                } label: {
                    HStack {
                        Image(systemName: "link.circle.fill")
                        Text("Continue with LinkedIn")
                    }
                    .font(.headline)
                    .foregroundColor(ThemeColors.textOnDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(ThemeColors.slateViolet)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                
                #if DEBUG
                // Demo button
                Button {
                    AppState.shared.signIn(user: AppState.UserInfo(
                        id: "demo_user",
                        email: "demo@jobmatchnow.ai",
                        providers: ["demo"]
                    ))
                } label: {
                    Text("Skip for Demo")
                        .foregroundColor(ThemeColors.mistBlue)
                }
                #endif
                
                // Error message
                if let error = authManager.error {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(ThemeColors.errorRed)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
        .statusBarLightContent()
        .onTapGesture {
            focusedField = nil
        }
        .alert("Account Created", isPresented: $showAlert) {
            Button("OK") {
                authMode = .signIn
                password = ""
                confirmPassword = ""
            }
        } message: {
            Text(alertMessage ?? "Please check your email to confirm your account, then sign in.")
        }
    }
    
    // MARK: - Form Validation
    
    private var canSubmit: Bool {
        guard !isSubmitting else { return false }
        
        let emailValid = !email.isEmpty && email.contains("@")
        let passwordValid = password.count >= 6
        
        if authMode == .signUp {
            return emailValid && passwordValid && password == confirmPassword && !confirmPassword.isEmpty
        }
        return emailValid && passwordValid
    }
    
    // MARK: - Submit Form
    
    private func submitForm() {
        guard canSubmit else { return }
        
        focusedField = nil
        isSubmitting = true
        
        Task {
            defer { isSubmitting = false }
            
            do {
                if authMode == .signIn {
                    try await authManager.signInWithEmail(email: email, password: password)
                } else {
                    try await authManager.signUpWithEmail(email: email, password: password)
                }
            } catch let error as AuthManager.AuthError {
                if error.localizedDescription.contains("check your email") {
                    alertMessage = "Account created! Please check your email to confirm your account, then sign in."
                    showAlert = true
                }
                print("[AuthView] Error: \(error.localizedDescription)")
            } catch {
                print("[AuthView] Error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    AuthView()
}
