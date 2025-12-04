import SwiftUI

// MARK: - Main Tab View

/// Root tab view with Search, Insights, and Dashboard tabs
struct MainTabView: View {
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            // Search Tab
            NavigationStack {
                SearchUploadView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(AppState.Tab.search)
            
            // Insights Tab
            NavigationStack {
                InsightsView()
            }
            .tabItem {
                Label("Insights", systemImage: "sparkles")
            }
            .tag(AppState.Tab.insights)
            
            // Dashboard Tab
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "rectangle.stack")
            }
            .tag(AppState.Tab.dashboard)
        }
        .tint(ThemeColors.primaryBrand)  // Brand purple for tab bar accents
    }
}

#Preview {
    MainTabView()
}
