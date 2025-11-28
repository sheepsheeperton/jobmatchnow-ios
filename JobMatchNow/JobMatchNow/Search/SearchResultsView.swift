import SwiftUI

// MARK: - Job Filter Enum

enum JobFilter: String, CaseIterable {
    case all = "All"
    case direct = "Direct"
    case adjacent = "Adjacent"
}

// MARK: - Search Results View

/// Displays job matches with filtering and actions
struct SearchResultsView: View {
    let jobs: [Job]
    let viewToken: String
    
    @StateObject private var appState = AppState.shared
    @State private var selectedFilter: JobFilter = .all
    @State private var showActionMenu = false
    @State private var showSettings = false
    @State private var selectedJobURL: URL?
    @State private var showSafari = false
    @Environment(\.dismiss) private var dismiss
    
    var filteredJobs: [Job] {
        switch selectedFilter {
        case .all:
            return jobs
        case .direct:
            return jobs.filter { $0.category?.lowercased() == "direct" }
        case .adjacent:
            return jobs.filter { $0.category?.lowercased() == "adjacent" }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Your Job Matches")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Found \(jobs.count) matches based on your résumé")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Filter segmented control
            Picker("Filter", selection: $selectedFilter) {
                ForEach(JobFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            // Results count for current filter
            if selectedFilter != .all {
                Text("\(filteredJobs.count) \(selectedFilter.rawValue.lowercased()) matches")
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
                        .foregroundColor(Theme.primaryBlue)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(job.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(job.company_name)
                        .font(.subheadline)
                        .foregroundColor(Theme.primaryBlue)
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
            
            // Action button
            if let jobURL = job.job_url, let url = URL(string: jobURL) {
                Button(action: {
                    onViewDetails(url)
                }) {
                    Text("View Details")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.primaryBlue)
                        .cornerRadius(Theme.CornerRadius.small)
                }
            } else {
                Button(action: {}) {
                    Text("Details Unavailable")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray)
                        .cornerRadius(Theme.CornerRadius.small)
                }
                .disabled(true)
            }
        }
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
            return Theme.directCategory
        case "adjacent":
            return Theme.adjacentCategory
        default:
            return Theme.primaryBlue
        }
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

