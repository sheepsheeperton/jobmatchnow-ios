import SwiftUI
import Combine
import AuthenticationServices

// MARK: - Auth Manager

/// Handles authentication with Supabase OAuth providers
final class AuthManager: ObservableObject {
    // MARK: - Singleton
    static let shared = AuthManager()
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var error: AuthError?
    
    // MARK: - Supabase Configuration
    private let supabaseURL = "https://nxbhfoqaoaeiguoldnng.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54Ymhmb3Fhb2FlaWd1b2xkbm5nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI2OTM3MDIsImV4cCI6MjA3ODI2OTcwMn0.USnk23E4MW9jnFPZ3WTYYsiRQ_ajy2ro6FT-10qwdEs"
    private let redirectURL = "jobmatchnow://auth/callback"
    
    // MARK: - Session Storage Keys
    private let accessTokenKey = "supabase_access_token"
    private let refreshTokenKey = "supabase_refresh_token"
    private let userIdKey = "supabase_user_id"
    private let userEmailKey = "supabase_user_email"
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Auth Error
    
    enum AuthError: LocalizedError {
        case invalidURL
        case invalidResponse
        case networkError(Error)
        case authenticationFailed(String)
        case noSession
        case tokenExpired
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid authentication URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .authenticationFailed(let message):
                return message
            case .noSession:
                return "No active session"
            case .tokenExpired:
                return "Session expired. Please sign in again."
            }
        }
    }
    
    // MARK: - Check Existing Session
    
    func checkExistingSession() async -> Bool {
        // Check if we have stored tokens
        guard let accessToken = UserDefaults.standard.string(forKey: accessTokenKey),
              let userId = UserDefaults.standard.string(forKey: userIdKey) else {
            print("[AuthManager] No stored session found")
            return false
        }
        
        // Verify token is still valid by making a request to Supabase
        do {
            let isValid = try await verifyToken(accessToken)
            if isValid {
                let email = UserDefaults.standard.string(forKey: userEmailKey)
                AppState.shared.signIn(user: AppState.UserInfo(
                    id: userId,
                    email: email,
                    providers: [] // We could store this too
                ))
                print("[AuthManager] Existing session is valid")
                return true
            }
        } catch {
            print("[AuthManager] Token verification failed: \(error)")
        }
        
        // Try to refresh the token
        if let refreshToken = UserDefaults.standard.string(forKey: refreshTokenKey) {
            do {
                let newSession = try await refreshSession(refreshToken)
                if newSession {
                    print("[AuthManager] Session refreshed successfully")
                    return true
                }
            } catch {
                print("[AuthManager] Session refresh failed: \(error)")
            }
        }
        
        // Clear invalid session
        clearSession()
        return false
    }
    
    // MARK: - LinkedIn OAuth (Web-based)
    
    func signInWithLinkedIn() async throws {
        try await signInWithOAuth(provider: "linkedin_oidc")
    }
    
    private func signInWithOAuth(provider: String) async throws {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Build OAuth URL
        guard var components = URLComponents(string: "\(supabaseURL)/auth/v1/authorize") else {
            throw AuthError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "provider", value: provider),
            URLQueryItem(name: "redirect_to", value: redirectURL)
        ]
        
        guard let authURL = components.url else {
            throw AuthError.invalidURL
        }
        
        print("[AuthManager] Starting OAuth flow with URL: \(authURL)")
        
        // Open in ASWebAuthenticationSession for secure OAuth
        let callbackURLScheme = "jobmatchnow"
        
        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: callbackURLScheme
        ) { callbackURL, error in
            Task { @MainActor in
                if let error = error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        print("[AuthManager] User cancelled login")
                    } else {
                        self.error = .networkError(error)
                    }
                    return
                }
                
                if let callbackURL = callbackURL {
                    await self.handleOAuthCallback(callbackURL)
                }
            }
        }
        
        session.prefersEphemeralWebBrowserSession = false
        session.presentationContextProvider = AuthPresentationContext.shared
        
        session.start()
    }
    
    // MARK: - Email Sign In
    
    @MainActor
    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        print("[AuthManager] Starting sign in for: \(email)")
        
        guard let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password") else {
            isLoading = false
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("[AuthManager] Sending sign in request...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                isLoading = false
                error = .networkError(NSError(domain: "", code: -1))
                throw AuthError.networkError(NSError(domain: "", code: -1))
            }
            
            print("[AuthManager] Sign in response status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                try await parseAuthResponse(data)
                isLoading = false
                print("[AuthManager] Sign in successful")
            } else {
                isLoading = false
                let errorMsg = String(data: data, encoding: .utf8) ?? "Authentication failed"
                print("[AuthManager] Sign in error: \(errorMsg)")
                error = .authenticationFailed("Invalid email or password")
                throw AuthError.authenticationFailed("Invalid email or password")
            }
        } catch let networkError where !(networkError is AuthError) {
            isLoading = false
            print("[AuthManager] Network error: \(networkError)")
            error = .networkError(networkError)
            throw AuthError.networkError(networkError)
        }
    }
    
    // MARK: - Email Sign Up
    
    @MainActor
    func signUpWithEmail(email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        print("[AuthManager] Starting sign up for: \(email)")
        
        guard let url = URL(string: "\(supabaseURL)/auth/v1/signup") else {
            isLoading = false
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("[AuthManager] Sending sign up request...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                isLoading = false
                error = .networkError(NSError(domain: "", code: -1))
                throw AuthError.networkError(NSError(domain: "", code: -1))
            }
            
            print("[AuthManager] Sign up response status: \(httpResponse.statusCode)")
            let responseBody = String(data: data, encoding: .utf8) ?? "No body"
            print("[AuthManager] Response body: \(responseBody)")
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                // Check if email confirmation is required
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // If we got tokens, sign in immediately
                    if json["access_token"] != nil {
                        try await parseAuthResponse(data)
                        isLoading = false
                        print("[AuthManager] Sign up successful, user signed in")
                    } else {
                        // Email confirmation required
                        isLoading = false
                        error = .authenticationFailed("Please check your email to confirm your account")
                        throw AuthError.authenticationFailed("Please check your email to confirm your account")
                    }
                }
            } else {
                isLoading = false
                let errorMsg = String(data: data, encoding: .utf8) ?? "Sign up failed"
                print("[AuthManager] Sign up error: \(errorMsg)")
                
                // Parse error message
                if errorMsg.contains("already registered") || errorMsg.contains("already been registered") {
                    error = .authenticationFailed("This email is already registered. Please sign in instead.")
                    throw AuthError.authenticationFailed("This email is already registered. Please sign in instead.")
                } else if errorMsg.contains("password") {
                    error = .authenticationFailed("Password must be at least 6 characters")
                    throw AuthError.authenticationFailed("Password must be at least 6 characters")
                } else {
                    error = .authenticationFailed("Sign up failed. Please try again.")
                    throw AuthError.authenticationFailed("Sign up failed. Please try again.")
                }
            }
        } catch let networkError where !(networkError is AuthError) {
            isLoading = false
            print("[AuthManager] Network error: \(networkError)")
            error = .networkError(networkError)
            throw AuthError.networkError(networkError)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() async {
        // Call Supabase logout endpoint
        if let accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
            var request = URLRequest(url: URL(string: "\(supabaseURL)/auth/v1/logout")!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
            
            _ = try? await URLSession.shared.data(for: request)
        }
        
        clearSession()
        AppState.shared.signOut()
    }
    
    // MARK: - Private Helpers
    
    private func handleOAuthCallback(_ url: URL) async {
        print("[AuthManager] Handling OAuth callback: \(url)")
        
        // Parse the callback URL for tokens
        guard let fragment = url.fragment else {
            error = .authenticationFailed("No authentication data received")
            return
        }
        
        // Parse fragment (access_token=xxx&refresh_token=xxx&...)
        var params: [String: String] = [:]
        for pair in fragment.split(separator: "&") {
            let parts = pair.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                params[String(parts[0])] = String(parts[1])
            }
        }
        
        if let accessToken = params["access_token"],
           let refreshToken = params["refresh_token"] {
            // Store tokens
            UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
            UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
            
            // Get user info
            await fetchUserInfo(accessToken: accessToken)
        } else {
            error = .authenticationFailed("Invalid authentication response")
        }
    }
    
    private func fetchUserInfo(accessToken: String) async {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/user") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let id = json["id"] as? String {
                let email = json["email"] as? String
                
                // Store user info
                UserDefaults.standard.set(id, forKey: userIdKey)
                if let email = email {
                    UserDefaults.standard.set(email, forKey: userEmailKey)
                }
                
                // Extract providers
                var providers: [String] = []
                if let identities = json["identities"] as? [[String: Any]] {
                    providers = identities.compactMap { $0["provider"] as? String }
                }
                
                AppState.shared.signIn(user: AppState.UserInfo(
                    id: id,
                    email: email,
                    providers: providers
                ))
            }
        } catch {
            print("[AuthManager] Failed to fetch user info: \(error)")
        }
    }
    
    private func verifyToken(_ token: String) async throws -> Bool {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/user") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        
        return httpResponse.statusCode == 200
    }
    
    private func refreshSession(_ refreshToken: String) async throws -> Bool {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=refresh_token") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        let body = ["refresh_token": refreshToken]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return false
        }
        
        try await parseAuthResponse(data)
        return true
    }
    
    private func parseAuthResponse(_ data: Data) async throws {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let accessToken = json["access_token"] as? String,
              let refreshToken = json["refresh_token"] as? String else {
            throw AuthError.authenticationFailed("Invalid response format")
        }
        
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
        
        // Get user info from the response or fetch it
        if let user = json["user"] as? [String: Any],
           let id = user["id"] as? String {
            let email = user["email"] as? String
            UserDefaults.standard.set(id, forKey: userIdKey)
            if let email = email {
                UserDefaults.standard.set(email, forKey: userEmailKey)
            }
            
            AppState.shared.signIn(user: AppState.UserInfo(
                id: id,
                email: email,
                providers: []
            ))
        } else {
            await fetchUserInfo(accessToken: accessToken)
        }
    }
    
    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: userEmailKey)
    }
}

// MARK: - Presentation Context Provider

class AuthPresentationContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = AuthPresentationContext()
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

