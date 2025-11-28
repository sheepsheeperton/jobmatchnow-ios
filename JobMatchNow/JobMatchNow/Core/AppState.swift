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
    
    /// Current user info (if authenticated)
    @Published var currentUser: UserInfo?
    
    /// Last search info for quick access
    @Published var lastSearch: LastSearchInfo?
    
    /// Selected tab in MainTabView
    @Published var selectedTab: Tab = .search
    
    // MARK: - Tab Enum
    
    enum Tab: Int {
        case search = 0
        case dashboard = 1
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
        let label: String?
    }
    
    // MARK: - Initialization
    
    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
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

