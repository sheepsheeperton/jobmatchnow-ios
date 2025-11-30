//
//  DashboardModels.swift
//  JobMatchNow
//
//  Models for the Dashboard API response.
//

import Foundation

// MARK: - Dashboard Summary Response

/// Response from GET /api/me/dashboard endpoint
struct DashboardSummary: Decodable {
    let totalSearches: Int
    let totalJobsFound: Int
    let avgJobsPerSearch: Double
    let recentSessions: [DashboardSessionSummary]
    
    enum CodingKeys: String, CodingKey {
        case totalSearches = "total_searches"
        case totalJobsFound = "total_jobs_found"
        case avgJobsPerSearch = "avg_jobs_per_search"
        case recentSessions = "recent_sessions"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        totalSearches = try container.decodeIfPresent(Int.self, forKey: .totalSearches) ?? 0
        totalJobsFound = try container.decodeIfPresent(Int.self, forKey: .totalJobsFound) ?? 0
        recentSessions = try container.decodeIfPresent([DashboardSessionSummary].self, forKey: .recentSessions) ?? []
        
        // Handle avgJobsPerSearch as either Double or String
        if let doubleValue = try? container.decode(Double.self, forKey: .avgJobsPerSearch) {
            avgJobsPerSearch = doubleValue
        } else if let stringValue = try? container.decode(String.self, forKey: .avgJobsPerSearch),
                  let parsed = Double(stringValue) {
            avgJobsPerSearch = parsed
        } else {
            avgJobsPerSearch = 0.0
        }
    }
    
    // MARK: - Initializer for previews/testing
    
    init(totalSearches: Int, totalJobsFound: Int, avgJobsPerSearch: Double, recentSessions: [DashboardSessionSummary]) {
        self.totalSearches = totalSearches
        self.totalJobsFound = totalJobsFound
        self.avgJobsPerSearch = avgJobsPerSearch
        self.recentSessions = recentSessions
    }
}

// MARK: - Dashboard Session Summary

/// Summary of a single search session from the dashboard API
/// Backend JSON format:
/// {
///   "search_session_id": "2dc0f0f3-...",
///   "created_at": "2025-11-29T18:52:17.621835+00:00",
///   "title_or_inferred_role": "Scheduler",
///   "total_jobs": 81,
///   "local_count": 10,
///   "national_count": 60,
///   "remote_count": 11,
///   "status": "completed",
///   "view_token": "HKWiNZBSwLAmSzLeo0eZ0Ych"
/// }
struct DashboardSessionSummary: Identifiable, Decodable {
    let id: String
    let title: String?
    let createdAt: Date
    let totalJobs: Int
    let localCount: Int
    let nationalCount: Int
    let remoteCount: Int
    let status: String?
    let viewToken: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "search_session_id"
        case title = "title_or_inferred_role"
        case createdAt = "created_at"
        case totalJobs = "total_jobs"
        case localCount = "local_count"
        case nationalCount = "national_count"
        case remoteCount = "remote_count"
        case status
        case viewToken = "view_token"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        totalJobs = try container.decodeIfPresent(Int.self, forKey: .totalJobs) ?? 0
        localCount = try container.decodeIfPresent(Int.self, forKey: .localCount) ?? 0
        nationalCount = try container.decodeIfPresent(Int.self, forKey: .nationalCount) ?? 0
        remoteCount = try container.decodeIfPresent(Int.self, forKey: .remoteCount) ?? 0
        status = try container.decodeIfPresent(String.self, forKey: .status)
        viewToken = try container.decodeIfPresent(String.self, forKey: .viewToken)
        
        // Parse date from ISO8601 string
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            createdAt = date
        } else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            createdAt = formatter.date(from: dateString) ?? Date()
        }
    }
    
    // MARK: - Computed Properties
    
    var displayTitle: String {
        if let title = title, !title.isEmpty {
            return title
        }
        return "Search #\(id.prefix(8))"
    }
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    var fullFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    var isCompleted: Bool {
        status?.lowercased() == "completed"
    }
    
    // MARK: - Initializer for previews/testing
    
    init(id: String, title: String?, createdAt: Date, totalJobs: Int, localCount: Int, nationalCount: Int, remoteCount: Int, status: String? = "completed", viewToken: String?) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.totalJobs = totalJobs
        self.localCount = localCount
        self.nationalCount = nationalCount
        self.remoteCount = remoteCount
        self.status = status
        self.viewToken = viewToken
    }
}

// MARK: - Sample Data

extension DashboardSummary {
    static let sample = DashboardSummary(
        totalSearches: 12,
        totalJobsFound: 487,
        avgJobsPerSearch: 40.6,
        recentSessions: DashboardSessionSummary.samples
    )
    
    static let empty = DashboardSummary(
        totalSearches: 0,
        totalJobsFound: 0,
        avgJobsPerSearch: 0.0,
        recentSessions: []
    )
}

extension DashboardSessionSummary {
    static let samples: [DashboardSessionSummary] = [
        DashboardSessionSummary(
            id: "session_1",
            title: "Chief Financial Officer",
            createdAt: Date().addingTimeInterval(-2400),
            totalJobs: 95,
            localCount: 15,
            nationalCount: 62,
            remoteCount: 18,
            status: "completed",
            viewToken: "token_abc123"
        ),
        DashboardSessionSummary(
            id: "session_2",
            title: "Senior iOS Developer",
            createdAt: Date().addingTimeInterval(-86400),
            totalJobs: 67,
            localCount: 12,
            nationalCount: 40,
            remoteCount: 15,
            status: "completed",
            viewToken: "token_def456"
        ),
        DashboardSessionSummary(
            id: "session_3",
            title: "Product Manager",
            createdAt: Date().addingTimeInterval(-259200),
            totalJobs: 43,
            localCount: 8,
            nationalCount: 28,
            remoteCount: 7,
            status: "completed",
            viewToken: "token_ghi789"
        )
    ]
}

