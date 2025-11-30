import SwiftUI

// MARK: - Results Source

enum ResultsSource {
    case currentSearch
    case historical(sessionId: String)
}

// MARK: - Search Results View

/// Displays job matches with filtering and actions
struct SearchResultsView: View {
    let viewToken: String
    var source: ResultsSource = .currentSearch
    
    @StateObject private var viewModel: ResultsViewModel
    @StateObject private var appState = AppState.shared
    @StateObject private var explanationManager: ExplanationManager
    @State private var searchText = ""
    @State private var showActionMenu = false
    @State private var showSettings = false
    @State private var selectedJobURL: URL?
    @State private var showSafari = false
    @State private var showSavePrompt = true
    @Environment(\.dismiss) private var dismiss
    
    // Custom initializer to create ViewModels with viewToken
    init(jobs: [Job], viewToken: String, source: ResultsSource = .currentSearch, hasLocalJobs: Bool = true) {
        self.viewToken = viewToken
        self.source = source
        self._viewModel = StateObject(wrappedValue: ResultsViewModel(jobs: jobs, viewToken: viewToken, hasLocalJobs: hasLocalJobs))
        self._explanationManager = StateObject(wrappedValue: ExplanationManager(viewToken: viewToken))
    }
    
    var filteredJobs: [Job] {
        var result = viewModel.jobs
        
        // Apply search text filter
        if !searchText.isEmpty {
            result = result.filter { job in
                job.title.localizedCaseInsensitiveContains(searchText) ||
                job.company_name.localizedCaseInsensitiveContains(searchText) ||
                job.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Your Job Matches")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ThemeColors.textOnLight)
                    
                    Text("Found \(viewModel.jobs.count) matches based on your résumé")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
                }
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ThemeColors.textOnLight.opacity(0.5))
                    TextField("Search jobs...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(ThemeColors.textOnLight)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(ThemeColors.textOnLight.opacity(0.5))
                        }
                    }
                }
                .padding(12)
                .background(ThemeColors.surfaceWhite)
                .cornerRadius(Theme.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .stroke(ThemeColors.borderSubtle, lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.bottom, 12)
                
                // Job Bucket Filter (All | Remote | Local | National)
                JobBucketPicker(
                    selectedBucket: $viewModel.selectedBucket,
                    isLoading: viewModel.isRefreshing,
                    totalCount: viewModel.jobs.count
                )
                .padding(.horizontal)
                .padding(.bottom, 12)
                
                // Save prompt for new searches
                if case .currentSearch = source, showSavePrompt {
                    SaveSearchPromptView {
                        // Already saved via AppState
                        withAnimation {
                            showSavePrompt = false
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
                
                // Error message if present
                if let errorMessage = viewModel.errorMessage {
                    Button(action: { viewModel.retry() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(ThemeColors.warmAccent)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(ThemeColors.warmAccent.opacity(0.1))
                        .cornerRadius(Theme.CornerRadius.small)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
                
                // Results count (show when filtered by search text)
                if !searchText.isEmpty {
                    Text("\(filteredJobs.count) results")
                        .font(.caption)
                        .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
                        .padding(.bottom, 8)
                }
                
                // Job cards list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredJobs) { job in
                            JobCardView(
                                job: job,
                                explanationState: explanationManager.state(for: job.job_id),
                                isExpanded: explanationManager.isExpanded(job.job_id),
                                onToggleExpand: {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        explanationManager.toggleExpanded(job.job_id)
                                    }
                                },
                                onRetryExplanation: {
                                    explanationManager.retryExplanation(for: job.job_id)
                                },
                                onViewDetails: { url in
                                    selectedJobURL = url
                                    showSafari = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Loading overlay when refreshing
            if viewModel.isRefreshing {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(ThemeColors.primaryBrand)
                    Text("Loading \(viewModel.locationScope.displayName) jobs...")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.textOnLight)
                }
                .padding(24)
                .background(ThemeColors.surfaceWhite)
                .cornerRadius(Theme.CornerRadius.medium)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            }
        }
        .background(ThemeColors.surfaceLight)
        .statusBarDarkContent()  // Light background → dark status bar
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { startNewSearch() }) {
                        Label("Start New Search", systemImage: "magnifyingglass")
                    }
                    
                    Button(action: { openDashboard() }) {
                        Label("Open Dashboard", systemImage: "rectangle.stack")
                    }
                    
                    Divider()
                    
                    Button(action: { showSettings = true }) {
                        Label("Settings", systemImage: "gearshape")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: { logOut() }) {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
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
    }
    
    // MARK: - Actions
    
    private func startNewSearch() {
        // Pop to root of search stack
        dismiss()
    }
    
    private func openDashboard() {
        appState.switchToTab(.dashboard)
    }
    
    private func logOut() {
        Task {
            await AuthManager.shared.signOut()
        }
    }
}

// MARK: - Job Bucket Picker
// 4-button segmented control: All | Remote | Local | National

struct JobBucketPicker: View {
    @Binding var selectedBucket: JobBucket
    let isLoading: Bool
    let totalCount: Int
    
    private var bucketIcon: (JobBucket) -> String {
        return { bucket in
            switch bucket {
            case .all: return "square.grid.2x2.fill"
            case .remote: return "wifi"
            case .local: return "mappin.circle.fill"
            case .national: return "globe.americas.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(JobBucket.allCases, id: \.self) { bucket in
                Button(action: {
                    if !isLoading {
                        selectedBucket = bucket
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: bucketIcon(bucket))
                            .font(.caption)
                        Text(bucket.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedBucket == bucket ? ThemeColors.textOnDark : ThemeColors.textOnLight)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selectedBucket == bucket
                            ? ThemeColors.primaryComplement
                            : Color.clear
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading)
            }
        }
        .background(ThemeColors.surfaceWhite)
        .cornerRadius(Theme.CornerRadius.small)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                .stroke(ThemeColors.borderSubtle, lineWidth: 1)
        )
        .overlay(
            // Loading indicator overlay
            Group {
                if isLoading {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Loading...")
                            .font(.caption2)
                            .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ThemeColors.surfaceWhite.opacity(0.8))
                    .cornerRadius(Theme.CornerRadius.small)
                }
            }
        )
    }
}

// MARK: - Job Card View

struct JobCardView: View {
    let job: Job
    let explanationState: ExplanationState
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onRetryExplanation: () -> Void
    let onViewDetails: (URL) -> Void
    
    private var jobURL: URL? {
        guard let urlString = job.job_url else { return nil }
        return URL(string: urlString)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main card content (always visible)
            mainCardContent
            
            // "Why this matches you" row
            whyThisMatchesRow
            
            // Expanded explanation section
            if isExpanded {
                explanationSection
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Action button - primary CTA
            actionButton
        }
        .padding()
        .background(ThemeColors.surfaceWhite)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Main Card Content
    
    private var mainCardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(job.title)
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnLight)
                        .multilineTextAlignment(.leading)
                    
                    Text(job.company_name)
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.primaryComplement)
                }
                
                Spacer()
                
                // Remote badge
                if job.isRemote {
                    RemoteBadge()
                }
            }
            
            // Location
            HStack(spacing: 6) {
                Image(systemName: job.isRemote ? "globe" : "location.fill")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textOnLight.opacity(0.6))
                Text(job.location)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
            }
            
            // Posted date
            if let postedAt = job.posted_at {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(ThemeColors.textOnLight.opacity(0.6))
                    Text(postedAt)
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
                }
            }
        }
    }
    
    // MARK: - Why This Matches Row
    
    private var whyThisMatchesRow: some View {
        Button(action: onToggleExpand) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(ThemeColors.primaryBrand)
                
                Text("Why this matches you")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.primaryBrand)
                
                Spacer()
                
                if explanationState.isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(ThemeColors.primaryBrand)
                } else {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(ThemeColors.primaryBrand.opacity(0.7))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(ThemeColors.primaryBrand.opacity(0.08))
            .cornerRadius(Theme.CornerRadius.small)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 12)
    }
    
    // MARK: - Explanation Section
    
    @ViewBuilder
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch explanationState {
            case .idle, .loading:
                loadingExplanationView
                
            case .loaded(let explanation):
                loadedExplanationView(explanation)
                
            case .error(let message):
                errorExplanationView(message)
            }
        }
        .padding(.top, 12)
    }
    
    private var loadingExplanationView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
                .tint(ThemeColors.primaryComplement)
            
            Text("Analyzing your résumé match…")
                .font(.subheadline)
                .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
                .italic()
            
            Spacer()
        }
        .padding(12)
        .background(ThemeColors.softComplement.opacity(0.15))
        .cornerRadius(Theme.CornerRadius.small)
    }
    
    private func loadedExplanationView(_ explanation: JobExplanation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Summary paragraph
            if !explanation.explanationSummary.isEmpty {
                Text(explanation.explanationSummary)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.textOnLight)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Bullet points
            if !explanation.bullets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(explanation.bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(ThemeColors.primaryComplement)
                                .padding(.top, 2)
                            
                            Text(bullet)
                                .font(.subheadline)
                                .foregroundColor(ThemeColors.textOnLight.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(ThemeColors.softComplement.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.small)
    }
    
    private func errorExplanationView(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundColor(ThemeColors.warmAccent)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.textOnLight.opacity(0.7))
                
                Spacer()
            }
            
            Button(action: onRetryExplanation) {
                Text("Try Again")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.primaryComplement)
            }
        }
        .padding(12)
        .background(ThemeColors.warmAccent.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.small)
    }
    
    // MARK: - Action Button
    
    private var actionButton: some View {
        Button(action: {
            if let url = jobURL {
                onViewDetails(url)
            }
        }) {
            HStack {
                Text("View Details")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.textOnDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(jobURL != nil ? ThemeColors.primaryBrand : ThemeColors.borderSubtle)
                    .cornerRadius(Theme.CornerRadius.small)
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textOnLight.opacity(0.5))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(jobURL == nil)
        .padding(.top, 12)
    }
}

// MARK: - Remote Badge

struct RemoteBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "wifi")
                .font(.caption2)
            Text("Remote")
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(ThemeColors.primaryComplement)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(ThemeColors.primaryComplement.opacity(0.15))
        .cornerRadius(Theme.CornerRadius.small)
    }
}

// MARK: - Save Search Prompt

struct SaveSearchPromptView: View {
    let onSave: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "bookmark.fill")
                .foregroundColor(ThemeColors.primaryBrand)
            
            Text("Search saved to dashboard")
                .font(.subheadline)
                .foregroundColor(ThemeColors.textOnLight)
            
            Spacer()
            
            Button("Saved ✓") {
                onSave()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(ThemeColors.primaryBrand)
        }
        .padding(12)
        .background(ThemeColors.softComplement.opacity(0.2))
        .cornerRadius(Theme.CornerRadius.small)
    }
}

#Preview {
    let sampleJobs = [
        Job(id: "1", job_id: "job1", title: "iOS Developer", company_name: "Tech Corp", location: "Remote - Worldwide", posted_at: "2 days ago", job_url: "https://example.com", source_query: "iOS developer", category: "direct", isRemote: true),
        Job(id: "2", job_id: "job2", title: "Senior Swift Engineer", company_name: "StartupXYZ", location: "San Francisco, CA", posted_at: "1 week ago", job_url: "https://example.com", source_query: "Swift developer", category: "direct", isRemote: false),
        Job(id: "3", job_id: "job3", title: "Product Manager", company_name: "Innovation Labs", location: "Remote - US Only", posted_at: "3 days ago", job_url: "https://example.com", source_query: "product manager", category: "adjacent", isRemote: true),
        Job(id: "4", job_id: "job4", title: "Backend Engineer", company_name: "DataFlow Inc", location: "New York, NY", posted_at: "5 days ago", job_url: "https://example.com", source_query: "backend engineer", category: "direct", isRemote: false)
    ]
    
    return NavigationStack {
        SearchResultsView(jobs: sampleJobs, viewToken: "test_token")
    }
}
