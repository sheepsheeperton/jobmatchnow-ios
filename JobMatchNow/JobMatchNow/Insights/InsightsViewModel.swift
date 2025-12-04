//
//  InsightsViewModel.swift
//  JobMatchNow
//
//  ViewModel for the Insights screen.
//  Displays resume score, feedback, and suggested roles with AI explanations.
//

import SwiftUI
import Combine

// MARK: - Insights View State

enum InsightsViewState: Equatable {
    case loading
    case loaded
    case error(String)
    case empty
}

// MARK: - Insights View Model

@MainActor
final class InsightsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current view state
    @Published private(set) var viewState: InsightsViewState = .loading
    
    /// Resume quality score (0-100)
    @Published private(set) var resumeScore: Int?
    
    /// Resume feedback summary
    @Published private(set) var resumeFeedback: String?
    
    /// Suggested roles from AI analysis
    @Published private(set) var suggestedRoles: [String] = []
    
    /// Role explanations cache: role → structured response
    @Published private(set) var roleExplanations: [String: RoleSnippetResponse] = [:]
    
    /// Currently expanded role (only one at a time)
    @Published var expandedRole: String?
    
    /// Whether we're loading an explanation
    @Published private(set) var isLoadingExplanation = false
    
    /// Error message for explanation fetch
    @Published private(set) var explanationError: String?
    
    // MARK: - Private Properties
    
    private let apiService: APIService
    private let appState: AppState
    
    // MARK: - Initialization
    
    init(apiService: APIService = .shared, appState: AppState = .shared) {
        self.apiService = apiService
        self.appState = appState
    }
    
    // MARK: - Public Methods
    
    /// Load insights from the latest search session
    func loadLatestSessionInsights() async {
        viewState = .loading
        
        // Get latest view token from AppState
        guard let lastSearch = appState.lastSearch else {
            viewState = .empty
            print("[InsightsViewModel] No recent search session found")
            return
        }
        
        let viewToken = lastSearch.viewToken
        print("[InsightsViewModel] Loading insights for viewToken: \(viewToken.prefix(12))...")
        
        do {
            let sessionStatus = try await apiService.getSessionStatus(viewToken: viewToken)
            
            // Update resume score
            if let score = sessionStatus.resume_score {
                resumeScore = score
                resumeFeedback = sessionStatus.resume_feedback
                print("[InsightsViewModel] Resume score: \(score)")
            }
            
            // Update suggested roles
            if let roles = sessionStatus.realistic_target_roles, !roles.isEmpty {
                suggestedRoles = roles
                print("[InsightsViewModel] Suggested roles: \(roles.joined(separator: ", "))")
            }
            
            // Determine view state
            if resumeScore != nil || !suggestedRoles.isEmpty {
                viewState = .loaded
            } else {
                viewState = .empty
            }
            
        } catch {
            viewState = .error("Failed to load insights. Please try again.")
            print("[InsightsViewModel] ❌ Error loading insights: \(error)")
        }
    }
    
    /// Toggle explanation for a role
    func toggleRoleExplanation(_ role: String) {
        if expandedRole == role {
            // Collapse if already expanded
            expandedRole = nil
        } else {
            // Expand and fetch if needed
            expandedRole = role
            
            // Fetch explanation if not cached
            if roleExplanations[role] == nil {
                Task {
                    await fetchRoleExplanation(role: role)
                }
            }
        }
    }
    
    /// Fetch AI explanation for why the user might be a good fit for a role
    func fetchRoleExplanation(role: String) async {
        guard let lastSearch = appState.lastSearch else { return }
        
        isLoadingExplanation = true
        explanationError = nil
        
        do {
            let response = try await apiService.fetchRoleExplanation(
                role: role,
                viewToken: lastSearch.viewToken
            )
            
            roleExplanations[role] = response
            isLoadingExplanation = false
            
            print("[InsightsViewModel] ✅ Fetched explanation for role: \(role) - \(response.bullets.count) bullets")
            
        } catch {
            isLoadingExplanation = false
            explanationError = "Could not load explanation"
            print("[InsightsViewModel] ❌ Error fetching role explanation: \(error)")
        }
    }
    
    /// Retry loading insights
    func retry() {
        Task {
            await loadLatestSessionInsights()
        }
    }
}

// MARK: - Preview Helper

extension InsightsViewModel {
    static var preview: InsightsViewModel {
        let vm = InsightsViewModel()
        vm.resumeScore = 85
        vm.resumeFeedback = "Your résumé demonstrates strong experience in financial analysis and accounting. Consider highlighting specific achievements with quantifiable results. Your technical skills section could benefit from including relevant software proficiencies."
        vm.suggestedRoles = ["Senior Accountant", "Financial Analyst", "Accounting Manager", "Budget Analyst"]
        vm.viewState = .loaded
        return vm
    }
    
    static var emptyPreview: InsightsViewModel {
        let vm = InsightsViewModel()
        vm.viewState = .empty
        return vm
    }
}

