import SwiftUI

// MARK: - Job Filter Enum

enum JobFilter: String, CaseIterable {
    case all = "All"
    case direct = "Direct"
    case adjacent = "Adjacent"
}

// MARK: - Results Source

enum ResultsSource {
    case currentSearch
    case historical(sessionId: String)
}

// MARK: - Search Results View

/// Displays job matches with filtering and actions
struct SearchResultsView: View {
    let jobs: [Job]
    let viewToken: String
    var source: ResultsSource = .currentSearch
    
    @StateObject private var appState = AppState.shared
    @State private var selectedFilter: JobFilter = .all
    @State private var searchText = ""
    @State private var showActionMenu = false
    @State private var showSettings = false
    @State private var selectedJobURL: URL?
    @State private var showSafari = false
    @State private var showSavePrompt = true
    @Environment(\.dismiss) private var dismiss
    
    // Computed counts
    var directCount: Int {
        jobs.filter { $0.category?.lowercased() == "direct" }.count
    }
    
    var adjacentCount: Int {
        jobs.filter { $0.category?.lowercased() == "adjacent" }.count
    }
    
    var filteredJobs: [Job] {
        var result = jobs
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .direct:
            result = result.filter { $0.category?.lowercased() == "direct" }
        case .adjacent:
            result = result.filter { $0.category?.lowercased() == "adjacent" }
        }
        
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
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Your Job Matches")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(ThemeColors.midnight)
                
                Text("Found \(jobs.count) matches based on your résumé")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search jobs...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(ThemeColors.surfaceWhite)
            .cornerRadius(Theme.CornerRadius.small)
            .padding(.horizontal)
            .padding(.bottom, 12)
            
            // Filter segmented control with counts
            Picker("Filter", selection: $selectedFilter) {
                Text("All (\(jobs.count))").tag(JobFilter.all)
                Text("Direct (\(directCount))").tag(JobFilter.direct)
                Text("Adjacent (\(adjacentCount))").tag(JobFilter.adjacent)
            }
            .pickerStyle(SegmentedPickerStyle())
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
            
            // Results count
            if !searchText.isEmpty || selectedFilter != .all {
                Text("\(filteredJobs.count) results")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
            }
            
            // Job cards list
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredJobs) { job in
                        JobCardView(job: job) { url in
                            selectedJobURL = url
                            showSafari = true
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeColors.surfaceLight)
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
                        .foregroundColor(ThemeColors.primaryComplement)
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

// MARK: - Job Card View

struct JobCardView: View {
    let job: Job
    let onViewDetails: (URL) -> Void
    
    private var jobURL: URL? {
        guard let urlString = job.job_url else { return nil }
        return URL(string: urlString)
    }
    
    var body: some View {
        Button(action: {
            if let url = jobURL {
                onViewDetails(url)
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(job.title)
                            .font(.headline)
                            .foregroundColor(ThemeColors.midnight)
                            .multilineTextAlignment(.leading)
                        
                        Text(job.company_name)
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.primaryComplement)
                    }
                    
                    Spacer()
                    
                    // Category badge
                    if let category = job.category {
                        CategoryBadge(category: category)
                    }
                }
                
                // Location
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(job.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Posted date
                if let postedAt = job.posted_at {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(postedAt)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Action button - primary CTA uses brand orange
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
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(ThemeColors.surfaceWhite)
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(jobURL == nil)
    }
}

// MARK: - Category Badge

struct CategoryBadge: View {
    let category: String
    
    var body: some View {
        Text(category)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(badgeColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(badgeColor.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.small)
    }
    
    private var badgeColor: Color {
        switch category.lowercased() {
        case "direct":
            return ThemeColors.primaryComplement
        case "adjacent":
            return ThemeColors.softComplement  // Replace purple with approved color
        default:
            return ThemeColors.primaryBrand
        }
    }
}

// MARK: - Save Search Prompt

struct SaveSearchPromptView: View {
    let onSave: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "bookmark")
                .foregroundColor(ThemeColors.primaryBrand)
            
            Text("Save this search to revisit later")
                .font(.subheadline)
                .foregroundColor(ThemeColors.midnight)
            
            Spacer()
            
            Button("Saved ✓") {
                onSave()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(ThemeColors.primaryBrand)
        }
        .padding(12)
        .background(ThemeColors.softComplement.opacity(0.3))
        .cornerRadius(Theme.CornerRadius.small)
    }
}

#Preview {
    let sampleJobs = [
        Job(id: "1", job_id: "job1", title: "iOS Developer", company_name: "Tech Corp", location: "Remote", posted_at: "2 days ago", job_url: "https://example.com", source_query: "iOS developer", category: "direct"),
        Job(id: "2", job_id: "job2", title: "Senior Swift Engineer", company_name: "StartupXYZ", location: "San Francisco, CA", posted_at: "1 week ago", job_url: "https://example.com", source_query: "Swift developer", category: "direct"),
        Job(id: "3", job_id: "job3", title: "Product Manager", company_name: "Innovation Labs", location: "Austin, TX", posted_at: "3 days ago", job_url: "https://example.com", source_query: "product manager", category: "adjacent")
    ]
    
    return NavigationStack {
        SearchResultsView(jobs: sampleJobs, viewToken: "test_token")
    }
}
