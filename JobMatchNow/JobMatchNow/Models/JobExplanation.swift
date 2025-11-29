//
//  JobExplanation.swift
//  JobMatchNow
//
//  Models for the AI-generated job explanation feature.
//

import Foundation

// MARK: - Job Explanation Response

/// Response from POST /api/jobs/explanation endpoint
struct JobExplanation: Decodable, Equatable {
    let explanationSummary: String
    let bullets: [String]
    
    enum CodingKeys: String, CodingKey {
        case explanationSummary = "explanation_summary"
        case bullets
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        explanationSummary = try container.decodeIfPresent(String.self, forKey: .explanationSummary) ?? ""
        bullets = try container.decodeIfPresent([String].self, forKey: .bullets) ?? []
    }
    
    // MARK: - Initializer for previews/testing
    
    init(explanationSummary: String, bullets: [String]) {
        self.explanationSummary = explanationSummary
        self.bullets = bullets
    }
}

// MARK: - Explanation Request

/// Request body for POST /api/jobs/explanation
struct ExplanationRequest: Encodable {
    let jobId: String
    let viewToken: String
    
    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case viewToken = "view_token"
    }
}

// MARK: - Explanation State

/// State for a single job's explanation loading
enum ExplanationState: Equatable {
    case idle
    case loading
    case loaded(JobExplanation)
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var explanation: JobExplanation? {
        if case .loaded(let exp) = self { return exp }
        return nil
    }
    
    var errorMessage: String? {
        if case .error(let msg) = self { return msg }
        return nil
    }
}

// MARK: - Sample Data

extension JobExplanation {
    static let sample = JobExplanation(
        explanationSummary: "This role aligns strongly with your background in iOS development and team leadership. Your experience building consumer-facing apps and mentoring junior developers directly matches their requirements for a Senior iOS Engineer.",
        bullets: [
            "5+ years iOS experience matches your 7 years in Swift/SwiftUI development",
            "Team leadership requirement aligns with your 3 years managing mobile teams",
            "Their focus on accessibility matches your portfolio of accessible app designs",
            "Remote-first culture fits your preference for distributed work"
        ]
    )
    
    static let shortSample = JobExplanation(
        explanationSummary: "Strong match based on your iOS development skills and startup experience.",
        bullets: [
            "Swift expertise matches job requirements",
            "Previous fintech experience relevant to this role"
        ]
    )
}

