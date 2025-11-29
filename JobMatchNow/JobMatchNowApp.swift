import SwiftUI

@main
struct JobMatchNowApp: App {
    // Initialize app state early
    @StateObject private var appState = AppState.shared
    
    init() {
        // Configure appearance
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .onOpenURL { url in
                    // Handle OAuth callback URLs
                    handleIncomingURL(url)
                }
        }
    }
    
    // MARK: - Appearance Configuration
    
    private func configureAppearance() {
        // Tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        // Set tint color - using primaryComplement for system alerts
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(ThemeColors.primaryComplement)
    }
    
    // MARK: - URL Handling
    
    private func handleIncomingURL(_ url: URL) {
        print("[JobMatchNowApp] Received URL: \(url)")
        
        // Handle OAuth callbacks (LinkedIn, etc.)
        if url.scheme == "jobmatchnow" && url.host == "auth" {
            print("[JobMatchNowApp] OAuth callback received")
        }
    }
}
