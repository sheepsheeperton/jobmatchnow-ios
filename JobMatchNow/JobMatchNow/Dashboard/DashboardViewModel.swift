//
//  DashboardViewModel.swift
//  JobMatchNow
//
//  ViewModel for the Dashboard feature.
//  Handles API calls, state management, and business logic.
//

import SwiftUI
import Combine

// MARK: - Dashboard View State

enum DashboardViewState: Equatable {
    case loading
    case loaded
    case error(String)
    case empty
}

// MARK: - Dashboard View Model

@MainActor
final class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current view state
    @Published private(set) var viewState: DashboardViewState = .loading
    
    /// Dashboard summary metrics
    @Published private(set) var summary: DashboardSummary?
    
    /// Recent search sessions
    @Published private(set) var recentSessions: [DashboardSessionSummary] = []
    
    /// Recently viewed jobs
    @Published private(set) var recentViewedJobs: [DashboardViewedJob] = []
    
    /// Whether we're currently loading session results for navigation
    @Published var isLoadingSession = false
    
    /// Jobs loaded for navigation to results
    @Published var loadedJobs: [Job] = []
    
    /// View token for navigation
    @Published var selectedViewToken: String = ""
    
    /// Triggers navigation to results
    @Published var navigateToResults = false
    
    // MARK: - Computed Properties
    
    var totalSearches: Int {
        summary?.totalSearches ?? 0
    }
    
    var uniqueJobsFound: Int {
        summary?.uniqueJobsFound ?? 0
    }
    
    var localJobsCount: Int {
        summary?.localJobsCount ?? 0
    }
    
    var nationalJobsCount: Int {
        summary?.nationalJobsCount ?? 0
    }
    
    var remoteJobsCount: Int {
        summary?.remoteJobsCount ?? 0
    }
    
    var avgJobsPerSearch: String {
        guard let avg = summary?.avgJobsPerSearch, avg > 0 else {
            return "—"
        }
        return String(format: "%.0f", avg)
    }
    
    var viewedJobsCount: Int {
        summary?.viewedJobsCount ?? 0
    }
    
    var starredJobsCount: Int {
        summary?.starredJobsCount ?? 0
    }
    
    var hasData: Bool {
        summary != nil && (summary!.totalSearches > 0 || !recentSessions.isEmpty)
    }
    
    var errorMessage: String? {
        if case .error(let message) = viewState {
            return message
        }
        return nil
    }
    
    // MARK: - Private Properties
    
    private let apiService: APIService
    
    // MARK: - Initialization
    
    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    // MARK: - Public Methods
    
    /// Load dashboard data from the API
    func loadDashboard() async {
        viewState = .loading
        
        do {
            let dashboardResponse = try await apiService.getDashboard()
            
            summary = dashboardResponse.summary
            recentSessions = dashboardResponse.recentSessions
            recentViewedJobs = dashboardResponse.recentViewedJobs
            
            if dashboardResponse.summary.totalSearches == 0 && dashboardResponse.recentSessions.isEmpty {
                viewState = .empty
            } else {
                viewState = .loaded
            }
            
            print("[DashboardViewModel] Loaded dashboard: \(dashboardResponse.summary.totalSearches) searches, \(dashboardResponse.recentSessions.count) sessions, \(dashboardResponse.recentViewedJobs.count) viewed jobs")
            
        } catch let error as APIError {
            // Handle specific API errors
            switch error {
            case .unauthorized:
                // User not signed in or session expired
                viewState = .error("Please sign in to view your dashboard.")
                print("[DashboardViewModel] Unauthorized - user needs to sign in")
                
            case .httpError(let code, _) where code == 404:
                // No dashboard data yet - show empty state
                summary = .empty
                recentSessions = []
                recentViewedJobs = []
                viewState = .empty
                print("[DashboardViewModel] No dashboard data yet (404)")
                
            default:
                viewState = .error(error.localizedDescription ?? "Failed to load dashboard")
                print("[DashboardViewModel] API error: \(error)")
            }
            
        } catch {
            viewState = .error("Unable to load your dashboard. Please try again.")
            print("[DashboardViewModel] Error loading dashboard: \(error)")
        }
    }
    
    /// Refresh dashboard data (for pull-to-refresh)
    func refreshDashboard() async {
        await loadDashboard()
    }
    
    /// Retry loading after an error
    func retry() {
        Task {
            await loadDashboard()
        }
    }
    
    /// Load jobs for a session and prepare for navigation
    func loadSessionResults(_ session: DashboardSessionSummary) {
        guard let viewToken = session.viewToken, !viewToken.isEmpty else {
            print("[DashboardViewModel] No view token for session \(session.id)")
            return
        }
        
        guard !isLoadingSession else {
            print("[DashboardViewModel] Already loading a session")
            return
        }
        
        isLoadingSession = true
        
        Task {
            do {
                let jobs = try await apiService.getJobs(viewToken: viewToken)
                
                loadedJobs = jobs
                selectedViewToken = viewToken
                isLoadingSession = false
                navigateToResults = true
                
                print("[DashboardViewModel] Loaded \(jobs.count) jobs for session \(session.id)")
                
            } catch {
                isLoadingSession = false
                print("[DashboardViewModel] Failed to load session results: \(error)")
            }
        }
    }
}

// MARK: - Preview Helper

extension DashboardViewModel {
    static var preview: DashboardViewModel {
        let vm = DashboardViewModel()
        vm.summary = .sample
        vm.recentSessions = DashboardSessionSummary.samples
        vm.recentViewedJobs = DashboardViewedJob.samples
        return vm
    }
    
    static var emptyPreview: DashboardViewModel {
        let vm = DashboardViewModel()
        vm.summary = .empty
        vm.recentSessions = []
        vm.recentViewedJobs = []
        return vm
    }
}
