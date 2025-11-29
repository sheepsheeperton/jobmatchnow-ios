//
//  ExplanationManager.swift
//  JobMatchNow
//
//  Manages AI-generated job explanation state for job cards.
//  Provides per-job loading, caching, and error handling.
//

import SwiftUI
import Combine

// MARK: - Explanation Manager

@MainActor
final class ExplanationManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Per-job explanation states keyed by job_id
    @Published private(set) var explanationStates: [String: ExplanationState] = [:]
    
    /// Set of job IDs that are currently expanded (showing explanation)
    @Published var expandedJobIds: Set<String> = []
    
    // MARK: - Private Properties
    
    private let apiService: APIService
    private let viewToken: String
    
    // MARK: - Initialization
    
    init(viewToken: String, apiService: APIService = .shared) {
        self.viewToken = viewToken
        self.apiService = apiService
    }
    
    // MARK: - Public Methods
    
    /// Get the explanation state for a specific job
    func state(for jobId: String) -> ExplanationState {
        explanationStates[jobId] ?? .idle
    }
    
    /// Check if a job card is expanded
    func isExpanded(_ jobId: String) -> Bool {
        expandedJobIds.contains(jobId)
    }
    
    /// Toggle expansion state for a job card
    func toggleExpanded(_ jobId: String) {
        if expandedJobIds.contains(jobId) {
            expandedJobIds.remove(jobId)
        } else {
            expandedJobIds.insert(jobId)
            // Auto-load explanation when expanding if not already loaded
            let currentState = state(for: jobId)
            if case .idle = currentState {
                loadExplanation(for: jobId)
            }
        }
    }
    
    /// Load explanation for a specific job
    func loadExplanation(for jobId: String) {
        let currentState = state(for: jobId)
        
        // Don't reload if already loading or loaded
        if case .loading = currentState { return }
        if case .loaded = currentState { return }
        
        // Set loading state
        explanationStates[jobId] = .loading
        
        Task {
            do {
                let explanation = try await apiService.getJobExplanation(
                    jobId: jobId,
                    viewToken: viewToken
                )
                
                explanationStates[jobId] = .loaded(explanation)
                print("[ExplanationManager] Loaded explanation for job \(jobId)")
                
            } catch let error as APIError {
                let message = error.localizedDescription ?? "Failed to load explanation"
                explanationStates[jobId] = .error(message)
                print("[ExplanationManager] Error loading explanation for \(jobId): \(message)")
                
            } catch {
                explanationStates[jobId] = .error("Unable to analyze this job match")
                print("[ExplanationManager] Unexpected error for \(jobId): \(error)")
            }
        }
    }
    
    /// Retry loading explanation for a job
    func retryExplanation(for jobId: String) {
        explanationStates[jobId] = .idle
        loadExplanation(for: jobId)
    }
    
    /// Clear all cached explanations
    func clearCache() {
        explanationStates.removeAll()
        expandedJobIds.removeAll()
    }
}

// MARK: - Preview Helper

extension ExplanationManager {
    static var preview: ExplanationManager {
        let manager = ExplanationManager(viewToken: "preview_token")
        manager.explanationStates["job1"] = .loaded(.sample)
        manager.explanationStates["job2"] = .loading
        manager.explanationStates["job3"] = .error("Network error")
        manager.expandedJobIds.insert("job1")
        return manager
    }
}

