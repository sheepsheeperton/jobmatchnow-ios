import SwiftUI
import Combine

// MARK: - App State

/// Central app state manager for authentication and navigation
final class AppState: ObservableObject {
    // MARK: - Singleton
    static let shared = AppState()
    
    // MARK: - Published Properties
    
    /// Current authentication state
    @Published var authState: AuthState = .loading
    
    /// Whether the user has completed onboarding
    @Published var hasCompletedOnboarding: Bool
    
    /// Whether the user has accepted data/AI processing consent
    @Published var hasAcceptedDataConsent: Bool
    
    /// Current user info (if authenticated)
    @Published var currentUser: UserInfo?
    
    /// Last search info for quick access
    @Published var lastSearch: LastSearchInfo?
    
    /// Selected tab in MainTabView
    @Published var selectedTab: Tab = .search
    
    // MARK: - Tab Enum
    
    enum Tab: Int {
        case search = 0
        case insights = 1
        case dashboard = 2
    }
    
    // MARK: - Auth State Enum
    
    enum AuthState: Equatable {
        case loading
        case unauthenticated
        case authenticated
    }
    
    // MARK: - User Info
    
    struct UserInfo: Equatable {
        let id: String
        let email: String?
        let providers: [String]
    }
    
    // MARK: - Last Search Info
    
    struct LastSearchInfo: Codable, Equatable {
        let viewToken: String
        let date: Date
        let totalMatches: Int
        let directMatches: Int
        let adjacentMatches: Int
        let label: String?  // Deprecated: use currentRoleTitle or lastSearchTitle
        
        // NEW: Semantic labels from backend
        let currentRoleTitle: String?   // User's current job title from résumé (e.g., "Co-owner / CFO")
        let lastSearchTitle: String?    // The search intent / inferred target role (e.g., "Accounting Specialist")
        
        // Backwards-compatible initializer
        init(
            viewToken: String,
            date: Date,
            totalMatches: Int,
            directMatches: Int = 0,
            adjacentMatches: Int = 0,
            label: String? = nil,
            currentRoleTitle: String? = nil,
            lastSearchTitle: String? = nil
        ) {
            self.viewToken = viewToken
            self.date = date
            self.totalMatches = totalMatches
            self.directMatches = directMatches
            self.adjacentMatches = adjacentMatches
            self.label = label
            self.currentRoleTitle = currentRoleTitle
            self.lastSearchTitle = lastSearchTitle
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.hasAcceptedDataConsent = UserDefaults.standard.bool(forKey: "hasAcceptedDataConsent")
        loadLastSearch()
    }
    
    // MARK: - Onboarding
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
    
    // MARK: - Data Consent
    
    func acceptDataConsent() {
        hasAcceptedDataConsent = true
        UserDefaults.standard.set(true, forKey: "hasAcceptedDataConsent")
    }
    
    func resetDataConsent() {
        hasAcceptedDataConsent = false
        UserDefaults.standard.set(false, forKey: "hasAcceptedDataConsent")
    }
    
    // MARK: - Authentication
    
    func signIn(user: UserInfo) {
        currentUser = user
        authState = .authenticated
    }
    
    func signOut() {
        currentUser = nil
        authState = .unauthenticated
        clearLastSearch()
    }
    
    // MARK: - Last Search Persistence
    
    func saveLastSearch(_ info: LastSearchInfo) {
        lastSearch = info
        if let encoded = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(encoded, forKey: "lastSearch")
        }
    }
    
    func loadLastSearch() {
        if let data = UserDefaults.standard.data(forKey: "lastSearch"),
           let decoded = try? JSONDecoder().decode(LastSearchInfo.self, from: data) {
            lastSearch = decoded
        }
    }
    
    func clearLastSearch() {
        lastSearch = nil
        UserDefaults.standard.removeObject(forKey: "lastSearch")
    }
    
    // MARK: - Navigation Helpers
    
    func switchToTab(_ tab: Tab) {
        selectedTab = tab
    }
}

