import SwiftUI

// MARK: - Dashboard View

/// Shows search history and metrics (triadic palette)
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var appState = AppState.shared
    @State private var showSettings = false
    @State private var sessionToDelete: DashboardSessionSummary?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .empty:
                emptyStateView
            case .error(let message):
                errorView(message: message)
            case .loaded:
                dashboardContent
            }
        }
        .background(ThemeColors.surfaceLight)
        .statusBarDarkContent()
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(ThemeColors.primaryBrand)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToResults) {
            SearchResultsView(
                jobs: viewModel.loadedJobs,
                viewToken: viewModel.selectedViewToken,
                source: .historical(sessionId: viewModel.selectedViewToken)
            )
        }
        .onAppear {
            Task {
                await viewModel.loadDashboard()
            }
        }
        .refreshable {
            await viewModel.refreshDashboard()
        }
        .alert("Delete Search?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                sessionToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let session = sessionToDelete {
                    viewModel.deleteSession(session)
                    sessionToDelete = nil
                }
            }
        } message: {
            if let session = sessionToDelete {
                Text("This will permanently delete \"\(session.displayTitle)\" from your search history.")
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(ThemeColors.accentGreen)
            Text("Loading your dashboard...")
                .font(.subheadline)
                .foregroundColor(ThemeColors.textSecondaryLight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(ThemeColors.errorRed.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundColor(ThemeColors.errorRed)
            }
            
            VStack(spacing: 8) {
                Text("Something Went Wrong")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.primaryBrand)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(ThemeColors.textSecondaryLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { viewModel.retry() }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.headline)
                .foregroundColor(ThemeColors.textOnDark)
                .frame(width: 160, height: 50)
                .background(ThemeColors.accentGreen)
                .cornerRadius(Theme.CornerRadius.medium)
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(ThemeColors.accentSand)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(ThemeColors.primaryBrand)
            }
            
            VStack(spacing: 8) {
                Text("No Search History")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.primaryBrand)
                
                Text("Your past job searches will appear here.\nStart by uploading your résumé!")
                    .font(.body)
                    .foregroundColor(ThemeColors.textSecondaryLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                appState.switchToTab(.search)
            }) {
                Text("Start a Search")
                    .font(.headline)
                    .foregroundColor(ThemeColors.textOnDark)
                    .frame(width: 200, height: 50)
                    .background(ThemeColors.accentGreen)
                    .cornerRadius(Theme.CornerRadius.medium)
            }
            .padding(.top, 16)
            
            Spacer()
        }
    }
    
    // MARK: - Dashboard Content
    
    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryStripCard
                
                if !viewModel.recentSessions.isEmpty {
                    recentSearchesSection
                }
            }
            .padding()
        }
    }
    
    // MARK: - Summary Strip Card
    
    private var summaryStripCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                SummaryMetricItem(
                    value: "\(viewModel.totalSearches)",
                    label: "Total Searches",
                    icon: "magnifyingglass",
                    color: ThemeColors.primaryBrand
                )
                
                Divider()
                    .frame(height: 50)
                
                SummaryMetricItem(
                    value: "\(viewModel.totalJobsFound)",
                    label: "Jobs Found",
                    icon: "briefcase.fill",
                    color: ThemeColors.accentGreen
                )
                
                Divider()
                    .frame(height: 50)
                
                SummaryMetricItem(
                    value: viewModel.avgJobsPerSearch,
                    label: "Avg per Search",
                    icon: "chart.bar.fill",
                    color: ThemeColors.brandPurpleMid
                )
            }
            .padding(.vertical, 20)
        }
        .background(ThemeColors.cardLight)
        .cornerRadius(Theme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(ThemeColors.borderSubtle, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Recent Searches Section
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                    .foregroundColor(ThemeColors.primaryBrand)
                
                Spacer()
                
                Text("Long press for options")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondaryLight)
            }
            .padding(.horizontal, 4)
            
            ForEach(viewModel.recentSessions) { session in
                RecentSessionCard(
                    session: session,
                    isLoading: viewModel.isLoadingSession && viewModel.selectedViewToken == session.viewToken,
                    onTap: {
                        viewModel.loadSessionResults(session)
                    },
                    onDelete: {
                        sessionToDelete = session
                        showDeleteConfirmation = true
                    }
                )
            }
        }
    }
}

// MARK: - Summary Metric Item (triadic)

struct SummaryMetricItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(ThemeColors.textSecondaryLight)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Recent Session Card (triadic)

struct RecentSessionCard: View {
    let session: DashboardSessionSummary
    let isLoading: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.displayTitle)
                            .font(.headline)
                            .foregroundColor(ThemeColors.primaryBrand)
                        
                        Text(session.dashboardSubtitle)
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.textSecondaryLight)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(ThemeColors.accentGreen)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(ThemeColors.textSecondaryLight)
                    }
                }
                
                Divider()
                
                HStack(spacing: 16) {
                    SessionStatItem(
                        value: session.totalJobs,
                        label: "Total",
                        color: ThemeColors.accentGreen
                    )
                    
                    SessionStatItem(
                        value: session.localCount,
                        label: "Local",
                        color: ThemeColors.softGrey
                    )
                    
                    SessionStatItem(
                        value: session.nationalCount,
                        label: "National",
                        color: ThemeColors.softGrey
                    )
                    
                    SessionStatItem(
                        value: session.remoteCount,
                        label: "Remote",
                        color: ThemeColors.softGrey
                    )
                }
            }
            .padding()
            .background(ThemeColors.cardLight)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(ThemeColors.borderSubtle, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading || session.viewToken == nil)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete Search", systemImage: "trash")
            }
        }
    }
}

// MARK: - Session Stat Item (triadic)

struct SessionStatItem: View {
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
                .foregroundColor(ThemeColors.textSecondaryLight)
        }
    }
}

#Preview("Dashboard - Loaded") {
    NavigationStack {
        DashboardView()
    }
}
