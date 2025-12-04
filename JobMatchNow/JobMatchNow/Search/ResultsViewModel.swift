//
//  ResultsViewModel.swift
//  JobMatchNow
//
//  ViewModel for the Search Results screen.
//  Manages jobs fetching with bucket filtering (All, Remote, Local, National).
//  Resume Score and Suggested Roles have moved to InsightsViewModel.
//

import SwiftUI
import Combine

// MARK: - Results View Model

@MainActor
final class ResultsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current list of jobs from the API
    @Published private(set) var jobs: [Job] = []
    
    /// Whether we're currently loading jobs
    @Published private(set) var isLoading = false
    
    /// Whether we're refreshing (bucket change) vs initial load
    @Published private(set) var isRefreshing = false
    
    /// Error message if fetch failed
    @Published private(set) var errorMessage: String?
    
    /// Current job bucket filter
    /// Defaults to .all to match initial load (no query params = all jobs)
    @Published var selectedBucket: JobBucket = .all {
        didSet {
            if oldValue != selectedBucket {
                Task {
                    await refreshJobs()
                }
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let viewToken: String
    private let apiService: APIService
    private let initialJobs: [Job]
    private let hasLocalJobs: Bool
    
    // MARK: - Initialization
    
    /// Initialize with pre-loaded jobs and viewToken
    /// - Parameters:
    ///   - jobs: Initial jobs already loaded (from upload flow, fetched with bucket = .all)
    ///   - viewToken: The session view token for API calls
    ///   - hasLocalJobs: Whether the user has a known location (affects default bucket UI hint)
    init(jobs: [Job], viewToken: String, hasLocalJobs: Bool = true, apiService: APIService = .shared) {
        self.initialJobs = jobs
        self.jobs = jobs
        self.viewToken = viewToken
        self.hasLocalJobs = hasLocalJobs
        self.apiService = apiService
        
        // Default to .all to match initial load (no query params = all jobs)
        // This ensures UI state matches the data being displayed
        self.selectedBucket = .all
        
        print("[ResultsViewModel] Initialized with \(jobs.count) jobs, default bucket: \(self.selectedBucket.rawValue)")
    }
    
    // MARK: - Public Methods
    
    /// Refresh jobs with current bucket filter
    func refreshJobs() async {
        isRefreshing = true
        errorMessage = nil
        
        print("[ResultsViewModel] Fetching jobs with bucket: \(selectedBucket.rawValue)")
        
        do {
            let fetchedJobs = try await apiService.getJobs(viewToken: viewToken, bucket: selectedBucket)
            jobs = fetchedJobs
            isRefreshing = false
            
            print("[ResultsViewModel] ✅ Refreshed jobs with bucket \(selectedBucket.rawValue): \(fetchedJobs.count) jobs")
            
        } catch {
            isRefreshing = false
            errorMessage = "Failed to load jobs. Tap to retry."
            print("[ResultsViewModel] ❌ Error refreshing jobs: \(error)")
        }
    }
    
    /// Toggle bookmark state for a job
    func toggleBookmark(for index: Int) {
        guard index >= 0, index < jobs.count else { return }
        
        let wasStarred = jobs[index].isStarred
        jobs[index].isStarred.toggle()
        
        let interactionType: JobInteractionType = wasStarred ? .unstar : .star
        
        // Fire and forget - API call happens in background
        Task {
            try? await apiService.trackJobInteraction(
                jobId: jobs[index].job_id,
                viewToken: viewToken,
                interactionType: interactionType
            )
        }
        
        print("[ResultsViewModel] \(wasStarred ? "Unstarred" : "Starred") job: \(jobs[index].title)")
    }
    
    /// Retry after error
    func retry() {
        Task {
            await refreshJobs()
        }
    }
    
    /// Reset to initial jobs (e.g., if user wants to undo bucket change)
    func resetToInitialJobs() {
        jobs = initialJobs
        selectedBucket = .all // Match the initial load default
        print("[ResultsViewModel] Reset to initial jobs (\(initialJobs.count) jobs), bucket: \(selectedBucket.rawValue)")
    }
}

// MARK: - Preview Helper

extension ResultsViewModel {
    static var preview: ResultsViewModel {
        let sampleJobs = [
            Job(id: "1", job_id: "job1", title: "iOS Developer", company_name: "Tech Corp", location: "Remote", posted_at: "2 days ago", job_url: "https://example.com", source_query: "iOS developer", category: "direct", isRemote: true),
            Job(id: "2", job_id: "job2", title: "Senior Swift Engineer", company_name: "StartupXYZ", location: "San Francisco, CA", posted_at: "1 week ago", job_url: "https://example.com", source_query: "Swift developer", category: "direct", isRemote: false)
        ]
        return ResultsViewModel(jobs: sampleJobs, viewToken: "preview_token")
    }
}
