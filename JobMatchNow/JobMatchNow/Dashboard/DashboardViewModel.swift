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
    
    var totalJobsFound: Int {
        summary?.totalJobsFound ?? 0
    }
    
    var avgJobsPerSearch: String {
        guard let avg = summary?.avgJobsPerSearch, avg > 0 else {
            return "—"
        }
        return String(format: "%.1f", avg)
    }
    
    var recentSessions: [DashboardSessionSummary] {
        summary?.recentSessions ?? []
    }
    
    var hasData: Bool {
        summary != nil && (summary!.totalSearches > 0 || !summary!.recentSessions.isEmpty)
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
            let dashboardSummary = try await apiService.getDashboard()
            
            summary = dashboardSummary
            
            if dashboardSummary.totalSearches == 0 && dashboardSummary.recentSessions.isEmpty {
                viewState = .empty
            } else {
                viewState = .loaded
            }
            
            print("[DashboardViewModel] Loaded dashboard: \(dashboardSummary.totalSearches) searches, \(dashboardSummary.recentSessions.count) recent sessions")
            
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
        return vm
    }
    
    static var emptyPreview: DashboardViewModel {
        let vm = DashboardViewModel()
        vm.summary = .empty
        return vm
    }
}

