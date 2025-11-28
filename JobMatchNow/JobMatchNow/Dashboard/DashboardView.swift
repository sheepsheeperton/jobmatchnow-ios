import SwiftUI

// MARK: - Dashboard View

/// Shows search history and allows navigation to past results
struct DashboardView: View {
    @StateObject private var appState = AppState.shared
    @State private var searchSessions: [SearchSession] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showSettings = false
    @State private var selectedSession: SearchSession?
    @State private var navigateToResults = false
    @State private var resultsJobs: [Job] = []
    @State private var resultsViewToken: String = ""
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if searchSessions.isEmpty {
                emptyStateView
            } else {
                sessionListView
            }
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(Theme.primaryBlue)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .navigationDestination(isPresented: $navigateToResults) {
            SearchResultsView(jobs: resultsJobs, viewToken: resultsViewToken, source: .historical(sessionId: resultsViewToken))
        }
        .onAppear {
            loadSearchHistory()
        }
        .refreshable {
            await refreshSearchHistory()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading your search history...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.primaryBlue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(Theme.primaryBlue)
            }
            
            VStack(spacing: 8) {
                Text("No Search History")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Your past job searches will appear here.\nStart by uploading your résumé!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                appState.switchToTab(.search)
            }) {
                Text("Start a Search")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Theme.primaryBlue)
                    .cornerRadius(Theme.CornerRadius.medium)
            }
            .padding(.top, 16)
            
            Spacer()
        }
    }
    
    // MARK: - Session List View
    
    private var sessionListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(searchSessions) { session in
                    SearchSessionCard(session: session) {
                        loadSessionResults(session)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadSearchHistory() {
        Task {
            // Simulate loading from Supabase
            // In production, this would call the API
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            await MainActor.run {
                // Check if we have a last search to show
                if let lastSearch = appState.lastSearch {
                    searchSessions = [
                        SearchSession(
                            id: UUID().uuidString,
                            viewToken: lastSearch.viewToken,
                            createdAt: lastSearch.date,
                            label: lastSearch.label,
                            totalMatches: lastSearch.totalMatches,
                            directMatches: lastSearch.directMatches,
                            adjacentMatches: lastSearch.adjacentMatches,
                            status: "completed"
                        )
                    ]
                } else {
                    searchSessions = []
                }
                isLoading = false
            }
        }
    }
    
    private func refreshSearchHistory() async {
        // Re-fetch from server
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            if let lastSearch = appState.lastSearch {
                searchSessions = [
                    SearchSession(
                        id: UUID().uuidString,
                        viewToken: lastSearch.viewToken,
                        createdAt: lastSearch.date,
                        label: lastSearch.label,
                        totalMatches: lastSearch.totalMatches,
                        directMatches: lastSearch.directMatches,
                        adjacentMatches: lastSearch.adjacentMatches,
                        status: "completed"
                    )
                ]
            }
        }
    }
    
    private func loadSessionResults(_ session: SearchSession) {
        Task {
            do {
                let jobs = try await APIService.shared.getJobs(viewToken: session.viewToken)
                
                await MainActor.run {
                    resultsJobs = jobs
                    resultsViewToken = session.viewToken
                    navigateToResults = true
                }
            } catch {
                print("Failed to load session results: \(error)")
            }
        }
    }
}

// MARK: - Search Session Card

struct SearchSessionCard: View {
    let session: SearchSession
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.displayLabel)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(session.fullFormattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Stats
                HStack(spacing: 24) {
                    StatItem(
                        value: session.totalMatches,
                        label: "Total",
                        color: Theme.primaryBlue
                    )
                    
                    StatItem(
                        value: session.directMatches,
                        label: "Direct",
                        color: Theme.directCategory
                    )
                    
                    StatItem(
                        value: session.adjacentMatches,
                        label: "Adjacent",
                        color: Theme.adjacentCategory
                    )
                }
            }
            .padding()
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}

