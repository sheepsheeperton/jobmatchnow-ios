//
//  ResultsViewModel.swift
//  JobMatchNow
//
//  ViewModel for the Search Results screen.
//  Manages jobs fetching, location scope, and loading states.
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
    
    /// Whether we're refreshing (scope change) vs initial load
    @Published private(set) var isRefreshing = false
    
    /// Error message if fetch failed
    @Published private(set) var errorMessage: String?
    
    /// Current location scope
    @Published var locationScope: LocationScope = .local {
        didSet {
            if oldValue != locationScope {
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
    ///   - jobs: Initial jobs already loaded (from upload flow)
    ///   - viewToken: The session view token for API calls
    ///   - hasLocalJobs: Whether the user has a known location (determines default scope)
    init(jobs: [Job], viewToken: String, hasLocalJobs: Bool = true, apiService: APIService = .shared) {
        self.initialJobs = jobs
        self.jobs = jobs
        self.viewToken = viewToken
        self.hasLocalJobs = hasLocalJobs
        self.apiService = apiService
        
        // Default to local if user has location, otherwise national
        self.locationScope = hasLocalJobs ? .local : .national
    }
    
    // MARK: - Public Methods
    
    /// Refresh jobs with current scope
    func refreshJobs() async {
        isRefreshing = true
        errorMessage = nil
        
        do {
            let fetchedJobs = try await apiService.getJobs(viewToken: viewToken, scope: locationScope)
            jobs = fetchedJobs
            isRefreshing = false
            
            print("[ResultsViewModel] Refreshed jobs with scope \(locationScope.rawValue): \(fetchedJobs.count) jobs")
            
        } catch {
            isRefreshing = false
            errorMessage = "Failed to load jobs. Tap to retry."
            print("[ResultsViewModel] Error refreshing jobs: \(error)")
        }
    }
    
    /// Retry after error
    func retry() {
        Task {
            await refreshJobs()
        }
    }
    
    /// Reset to initial jobs (e.g., if user wants to undo scope change)
    func resetToInitialJobs() {
        jobs = initialJobs
        locationScope = hasLocalJobs ? .local : .national
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

