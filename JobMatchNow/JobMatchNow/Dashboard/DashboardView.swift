import SwiftUI

// MARK: - Dashboard View

/// Shows search history and metrics, allowing navigation to past results
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
                        .foregroundColor(ThemeColors.midnight)
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
                // Summary Strip Card
                summaryStripCard
                
                // Recent Searches Section
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
                // Total Searches
                SummaryMetricItem(
                    value: "\(viewModel.totalSearches)",
                    label: "Total Searches",
                    icon: "magnifyingglass",
                    color: ThemeColors.primaryBrand
                )
                
                Divider()
                    .frame(height: 50)
                
                // Jobs Found
                SummaryMetricItem(
                    value: "\(viewModel.totalJobsFound)",
                    label: "Jobs Found",
                    icon: "briefcase.fill",
                    color: ThemeColors.primaryComplement
                )
                
                Divider()
                    .frame(height: 50)
                
                // Avg Matches
                SummaryMetricItem(
                    value: viewModel.avgJobsPerSearch,
                    label: "Avg per Search",
                    icon: "chart.bar.fill",
                    color: ThemeColors.deepComplement
                )
            }
            .padding(.vertical, 20)
        }
        .background(ThemeColors.surfaceWhite)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Recent Searches Section
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                    .foregroundColor(ThemeColors.textOnLight)
                
                Spacer()
                
                Text("Swipe to delete")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textOnLight.opacity(0.5))
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

// MARK: - Recent Session Card

struct RecentSessionCard: View {
    let session: DashboardSessionSummary
    let isLoading: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var showingDeleteButton = false
    private let deleteButtonWidth: CGFloat = 80
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button background
            HStack {
                Spacer()
                Button(action: onDelete) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                            .font(.title3)
                        Text("Delete")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: deleteButtonWidth, height: .infinity)
                }
                .frame(width: deleteButtonWidth)
                .background(ThemeColors.errorRed)
                .cornerRadius(Theme.CornerRadius.medium)
            }
            
            // Card content
            Button(action: {
                if showingDeleteButton {
                    withAnimation(.easeOut(duration: 0.2)) {
                        offset = 0
                        showingDeleteButton = false
                    }
                } else {
                    onTap()
                }
            }) {
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
                    
                    // Stats
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
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -deleteButtonWidth - 10)
                        } else if showingDeleteButton {
                            offset = min(-deleteButtonWidth + value.translation.width, 0)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.easeOut(duration: 0.2)) {
                            if value.translation.width < -deleteButtonWidth / 2 {
                                offset = -deleteButtonWidth
                                showingDeleteButton = true
                            } else {
                                offset = 0
                                showingDeleteButton = false
                            }
                        }
                    }
            )
        }
        .clipped()
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
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
        }
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
