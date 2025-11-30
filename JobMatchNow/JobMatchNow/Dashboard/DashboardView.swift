import SwiftUI

// MARK: - Dashboard View

/// Shows search history, metrics, and recently viewed jobs
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var appState = AppState.shared
    @State private var showSettings = false
    @State private var selectedJobURL: URL?
    @State private var showSafari = false
    
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
                        .foregroundColor(ThemeColors.midnight)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .sheet(isPresented: $showSafari) {
            if let url = selectedJobURL {
                SafariView(url: url)
                    .ignoresSafeArea()
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
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading your dashboard...")
                .font(.subheadline)
                .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
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
                    .foregroundColor(ThemeColors.textOnLight)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
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
                .background(ThemeColors.primaryBrand)
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
                    .fill(ThemeColors.softComplement.opacity(0.3))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(ThemeColors.primaryComplement)
            }
            
            VStack(spacing: 8) {
                Text("No Search History")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.textOnLight)
                
                Text("Your past job searches will appear here.\nStart by uploading your résumé!")
                    .font(.body)
                    .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
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
                    .background(ThemeColors.primaryBrand)
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
                // Main Summary Card
                summaryCard
                
                // Location Breakdown Row
                locationBreakdownRow
                
                // Activity Stats Row
                activityStatsRow
                
                // Recent Searches Section
                if !viewModel.recentSessions.isEmpty {
                    recentSearchesSection
                }
                
                // Recently Viewed Jobs Section
                if !viewModel.recentViewedJobs.isEmpty {
                    recentlyViewedJobsSection
                }
            }
            .padding()
        }
    }
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        HStack(spacing: 0) {
            // Total Searches
            SummaryMetricItem(
                value: "\(viewModel.totalSearches)",
                label: "Total Searches",
                icon: "magnifyingglass",
                color: ThemeColors.primaryBrand
            )
            
            Divider()
                .frame(height: 50)
            
            // Unique Jobs Found
            SummaryMetricItem(
                value: "\(viewModel.uniqueJobsFound)",
                label: "Unique Jobs",
                icon: "briefcase.fill",
                color: ThemeColors.primaryComplement
            )
            
            Divider()
                .frame(height: 50)
            
            // Avg per Search
            SummaryMetricItem(
                value: viewModel.avgJobsPerSearch,
                label: "Avg per Search",
                icon: "chart.bar.fill",
                color: ThemeColors.deepComplement
            )
        }
        .padding(.vertical, 20)
        .background(ThemeColors.surfaceWhite)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Location Breakdown Row
    
    private var locationBreakdownRow: some View {
        HStack(spacing: 12) {
            LocationMetricCard(
                value: viewModel.localJobsCount,
                label: "Local",
                icon: "mappin.circle.fill",
                color: ThemeColors.primaryBrand
            )
            
            LocationMetricCard(
                value: viewModel.nationalJobsCount,
                label: "National",
                icon: "globe.americas.fill",
                color: ThemeColors.primaryComplement
            )
            
            LocationMetricCard(
                value: viewModel.remoteJobsCount,
                label: "Remote",
                icon: "wifi",
                color: ThemeColors.deepComplement
            )
        }
    }
    
    // MARK: - Activity Stats Row
    
    private var activityStatsRow: some View {
        HStack(spacing: 12) {
            ActivityStatCard(
                value: viewModel.viewedJobsCount,
                label: "Jobs Viewed",
                icon: "eye.fill",
                color: ThemeColors.warmAccent
            )
            
            ActivityStatCard(
                value: viewModel.starredJobsCount,
                label: "Jobs Starred",
                icon: "star.fill",
                color: ThemeColors.primaryBrand
            )
        }
    }
    
    // MARK: - Recent Searches Section
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Searches")
                .font(.headline)
                .foregroundColor(ThemeColors.textOnLight)
                .padding(.horizontal, 4)
            
            ForEach(viewModel.recentSessions) { session in
                RecentSessionCard(
                    session: session,
                    isLoading: viewModel.isLoadingSession && viewModel.selectedViewToken == session.viewToken
                ) {
                    viewModel.loadSessionResults(session)
                }
            }
        }
    }
    
    // MARK: - Recently Viewed Jobs Section
    
    private var recentlyViewedJobsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Viewed Jobs")
                .font(.headline)
                .foregroundColor(ThemeColors.textOnLight)
                .padding(.horizontal, 4)
            
            ForEach(viewModel.recentViewedJobs) { job in
                ViewedJobCard(job: job) {
                    if let url = job.url {
                        selectedJobURL = url
                        showSafari = true
                    }
                }
            }
        }
    }
}

// MARK: - Summary Metric Item

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
                .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Location Metric Card

struct LocationMetricCard: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color)
                
                Text("\(value)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(.caption2)
                .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(ThemeColors.surfaceWhite)
        .cornerRadius(Theme.CornerRadius.small)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Activity Stat Card

struct ActivityStatCard: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(value)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(ThemeColors.textOnLight)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(ThemeColors.surfaceWhite)
        .cornerRadius(Theme.CornerRadius.small)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Recent Session Card

struct RecentSessionCard: View {
    let session: DashboardSessionSummary
    let isLoading: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.displayTitle)
                            .font(.headline)
                            .foregroundColor(ThemeColors.textOnLight)
                        
                        Text(session.fullFormattedDate)
                            .font(.caption)
                            .foregroundColor(ThemeColors.textOnLight.opacity(0.65))
                    }
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(ThemeColors.primaryComplement)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(ThemeColors.textOnLight.opacity(0.5))
                    }
                }
                
                Divider()
                
                // Stats - Updated to show Local/National/Remote
                HStack(spacing: 16) {
                    SessionStatItem(
                        value: session.totalJobs,
                        label: "Total",
                        color: ThemeColors.primaryBrand
                    )
                    
                    SessionStatItem(
                        value: session.localCount,
                        label: "Local",
                        color: ThemeColors.warmAccent
                    )
                    
                    SessionStatItem(
                        value: session.nationalCount,
                        label: "National",
                        color: ThemeColors.primaryComplement
                    )
                    
                    SessionStatItem(
                        value: session.remoteCount,
                        label: "Remote",
                        color: ThemeColors.deepComplement
                    )
                }
            }
            .padding()
            .background(ThemeColors.surfaceWhite)
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading || session.viewToken == nil)
    }
}

// MARK: - Session Stat Item

struct SessionStatItem: View {
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
        }
    }
}

// MARK: - Viewed Job Card

struct ViewedJobCard: View {
    let job: DashboardViewedJob
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Job Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeColors.textOnLight)
                        .lineLimit(1)
                    
                    Text(job.companyName)
                        .font(.caption)
                        .foregroundColor(ThemeColors.primaryComplement)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundColor(ThemeColors.textOnLight.opacity(0.5))
                        
                        Text(job.location)
                            .font(.caption)
                            .foregroundColor(ThemeColors.textOnLight.opacity(0.6))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(job.formattedViewedAt)
                            .font(.caption2)
                            .foregroundColor(ThemeColors.textOnLight.opacity(0.5))
                    }
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textOnLight.opacity(0.4))
            }
            .padding(12)
            .background(ThemeColors.surfaceWhite)
            .cornerRadius(Theme.CornerRadius.small)
            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(job.url == nil)
    }
}

// MARK: - Previews

#Preview("Dashboard - Loaded") {
    NavigationStack {
        DashboardView()
    }
}

#Preview("Dashboard - Empty") {
    NavigationStack {
        DashboardView()
    }
}
