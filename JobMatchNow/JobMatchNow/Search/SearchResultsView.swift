import SwiftUI

// MARK: - Results Source

enum ResultsSource {
    case currentSearch
    case historical(sessionId: String)
}

// MARK: - Search Results View

/// Displays job matches (triadic palette)
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
    
    init(jobs: [Job], viewToken: String, source: ResultsSource = .currentSearch, hasLocalJobs: Bool = true) {
        self.viewToken = viewToken
        self.source = source
        self._viewModel = StateObject(wrappedValue: ResultsViewModel(jobs: jobs, viewToken: viewToken, hasLocalJobs: hasLocalJobs))
        self._explanationManager = StateObject(wrappedValue: ExplanationManager(viewToken: viewToken))
    }
    
    var filteredJobs: [Job] {
        var result = viewModel.jobs
        
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
                        .foregroundColor(ThemeColors.primaryBrand)
                    
                    Text("Found \(viewModel.jobs.count) matches based on your résumé")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.textSecondaryLight)
                }
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ThemeColors.textSecondaryLight)
                    TextField("Search jobs...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(ThemeColors.textOnLight)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(ThemeColors.textSecondaryLight)
                        }
                    }
                }
                .padding(12)
                .background(ThemeColors.cardLight)
                .cornerRadius(Theme.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .stroke(ThemeColors.borderSubtle, lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.bottom, 12)
                
                // Job Bucket Filter
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
                        withAnimation {
                            showSavePrompt = false
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Button(action: { viewModel.retry() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(ThemeColors.warningAmber)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(ThemeColors.textSecondaryLight)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(ThemeColors.warningAmber.opacity(0.1))
                        .cornerRadius(Theme.CornerRadius.small)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
                
                // Results count
                if !searchText.isEmpty {
                    Text("\(filteredJobs.count) results")
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondaryLight)
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
            
            // Loading overlay
            if viewModel.isRefreshing {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(ThemeColors.accentGreen)
                    Text("Loading \(viewModel.selectedBucket.displayName) jobs...")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.textOnLight)
                }
                .padding(24)
                .background(ThemeColors.cardLight)
                .cornerRadius(Theme.CornerRadius.medium)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            }
        }
        .background(ThemeColors.surfaceLight)
        .statusBarDarkContent()
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
                        .foregroundColor(ThemeColors.primaryBrand)
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
    
    private func startNewSearch() {
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

// MARK: - Job Bucket Picker (triadic palette)

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
                            ? ThemeColors.accentGreen
                            : Color.clear
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading)
            }
        }
        .background(ThemeColors.cardLight)
        .cornerRadius(Theme.CornerRadius.small)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                .stroke(ThemeColors.borderSubtle, lineWidth: 1)
        )
        .overlay(
            Group {
                if isLoading {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Loading...")
                            .font(.caption2)
                            .foregroundColor(ThemeColors.textSecondaryLight)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ThemeColors.cardLight.opacity(0.9))
                    .cornerRadius(Theme.CornerRadius.small)
                }
            }
        )
    }
}

// MARK: - Job Card View (triadic palette)

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
            mainCardContent
            whyThisMatchesRow
            
            if isExpanded {
                explanationSection
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            actionButton
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
    
    private var mainCardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(job.title)
                        .font(.headline)
                        .foregroundColor(ThemeColors.primaryBrand)
                        .multilineTextAlignment(.leading)
                    
                    Text(job.company_name)
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.accentGreen)
                }
                
                Spacer()
                
                if job.isRemote {
                    RemoteBadge()
                }
            }
            
            HStack(spacing: 6) {
                Image(systemName: job.isRemote ? "globe" : "location.fill")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondaryLight)
                Text(job.location)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.textSecondaryLight)
            }
            
            if let postedAt = job.posted_at {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondaryLight)
                    Text(postedAt)
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.textSecondaryLight)
                }
            }
        }
    }
    
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
                        .tint(ThemeColors.accentGreen)
                } else {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(ThemeColors.primaryBrand.opacity(0.7))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(ThemeColors.accentSand.opacity(0.5))
            .cornerRadius(Theme.CornerRadius.small)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 12)
    }
    
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
                .tint(ThemeColors.accentGreen)
            
            Text("Analyzing your résumé match…")
                .font(.subheadline)
                .foregroundColor(ThemeColors.textSecondaryLight)
                .italic()
            
            Spacer()
        }
        .padding(12)
        .background(ThemeColors.accentSand.opacity(0.3))
        .cornerRadius(Theme.CornerRadius.small)
    }
    
    private func loadedExplanationView(_ explanation: JobExplanation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if !explanation.explanationSummary.isEmpty {
                Text(explanation.explanationSummary)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.textOnLight)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if !explanation.bullets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(explanation.bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(ThemeColors.accentGreen)
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
        .background(ThemeColors.accentSand.opacity(0.2))
        .cornerRadius(Theme.CornerRadius.small)
    }
    
    private func errorExplanationView(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundColor(ThemeColors.warningAmber)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.textSecondaryLight)
                
                Spacer()
            }
            
            Button(action: onRetryExplanation) {
                Text("Try Again")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.accentGreen)
            }
        }
        .padding(12)
        .background(ThemeColors.warningAmber.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.small)
    }
    
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
                    .background(jobURL != nil ? ThemeColors.accentGreen : ThemeColors.softGrey)
                    .cornerRadius(Theme.CornerRadius.small)
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondaryLight)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(jobURL == nil)
        .padding(.top, 12)
    }
}

// MARK: - Remote Badge (sand background)

struct RemoteBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "wifi")
                .font(.caption2)
            Text("Remote")
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(ThemeColors.primaryBrand)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(ThemeColors.accentSand)
        .cornerRadius(Theme.CornerRadius.small)
    }
}

// MARK: - Save Search Prompt (sand background)

struct SaveSearchPromptView: View {
    let onSave: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "bookmark.fill")
                .foregroundColor(ThemeColors.accentGreen)
            
            Text("Search saved to dashboard")
                .font(.subheadline)
                .foregroundColor(ThemeColors.primaryBrand)
            
            Spacer()
            
            Button("Saved ✓") {
                onSave()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(ThemeColors.accentGreen)
        }
        .padding(12)
        .background(ThemeColors.accentSand.opacity(0.5))
        .cornerRadius(Theme.CornerRadius.small)
    }
}

#Preview {
    let sampleJobs = [
        Job(id: "1", job_id: "job1", title: "iOS Developer", company_name: "Tech Corp", location: "Remote - Worldwide", posted_at: "2 days ago", job_url: "https://example.com", source_query: "iOS developer", category: "direct", isRemote: true),
        Job(id: "2", job_id: "job2", title: "Senior Swift Engineer", company_name: "StartupXYZ", location: "San Francisco, CA", posted_at: "1 week ago", job_url: "https://example.com", source_query: "Swift developer", category: "direct", isRemote: false)
    ]
    
    return NavigationStack {
        SearchResultsView(jobs: sampleJobs, viewToken: "test_token")
    }
}
