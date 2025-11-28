import SwiftUI

// MARK: - Main Tab View

/// Root tab view with Search and Dashboard tabs
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
            
            // Dashboard Tab
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "rectangle.stack")
            }
            .tag(AppState.Tab.dashboard)
        }
        .tint(Theme.primaryBlue)
    }
}

#Preview {
    MainTabView()
}

