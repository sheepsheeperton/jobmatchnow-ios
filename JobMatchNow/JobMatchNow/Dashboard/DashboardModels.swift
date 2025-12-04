//
//  DashboardModels.swift
//  JobMatchNow
//
//  Models for the Dashboard API response.
//

import Foundation

// MARK: - Dashboard API Response

/// Top-level response from GET /api/me/dashboard endpoint
/// Backend returns: { "summary": {...}, "recent_sessions": [...], "recent_starred_jobs": [...] }
struct DashboardAPIResponse: Decodable {
    let summary: DashboardSummaryMetrics
    let recentSessions: [DashboardSessionSummary]
    let recentStarredJobs: [DashboardSavedJob]
    
    enum CodingKeys: String, CodingKey {
        case summary
        case recentSessions = "recent_sessions"
        case recentStarredJobs = "recent_starred_jobs"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        summary = try container.decodeIfPresent(DashboardSummaryMetrics.self, forKey: .summary) ?? DashboardSummaryMetrics()
        recentSessions = try container.decodeIfPresent([DashboardSessionSummary].self, forKey: .recentSessions) ?? []
        recentStarredJobs = try container.decodeIfPresent([DashboardSavedJob].self, forKey: .recentStarredJobs) ?? []
    }
    
    // For previews/testing
    init(summary: DashboardSummaryMetrics, recentSessions: [DashboardSessionSummary], recentStarredJobs: [DashboardSavedJob] = []) {
        self.summary = summary
        self.recentSessions = recentSessions
        self.recentStarredJobs = recentStarredJobs
    }
}

// MARK: - Dashboard Saved Job

/// A saved/starred job from the dashboard API
struct DashboardSavedJob: Identifiable, Decodable {
    let id: String
    let title: String
    let company: String
    let location: String
    let jobUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "job_id"
        case title
        case company = "company_name"
        case location
        case jobUrl = "job_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        company = try container.decodeIfPresent(String.self, forKey: .company) ?? "Unknown Company"
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? "Location not specified"
        jobUrl = try container.decodeIfPresent(String.self, forKey: .jobUrl)
    }
    
    // For previews/testing
    init(id: String, title: String, company: String, location: String, jobUrl: String?) {
        self.id = id
        self.title = title
        self.company = company
        self.location = location
        self.jobUrl = jobUrl
    }
}

// MARK: - Dashboard Summary Metrics

/// Metrics from the "summary" object in the API response
/// Backend format:
/// {
///   "total_searches": 1,
///   "unique_jobs_found": 81,
///   "local_jobs_count": 0,
///   "national_jobs_count": 54,
///   "remote_jobs_count": 27,
///   "avg_jobs_per_search": 81,
///   "viewed_jobs_count": 0,
///   "starred_jobs_count": 0
/// }
struct DashboardSummaryMetrics: Decodable {
    let totalSearches: Int
    let uniqueJobsFound: Int
    let localJobsCount: Int
    let nationalJobsCount: Int
    let remoteJobsCount: Int
    let avgJobsPerSearch: Double
    let viewedJobsCount: Int
    let starredJobsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case totalSearches = "total_searches"
        case uniqueJobsFound = "unique_jobs_found"
        case localJobsCount = "local_jobs_count"
        case nationalJobsCount = "national_jobs_count"
        case remoteJobsCount = "remote_jobs_count"
        case avgJobsPerSearch = "avg_jobs_per_search"
        case viewedJobsCount = "viewed_jobs_count"
        case starredJobsCount = "starred_jobs_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        totalSearches = try container.decodeIfPresent(Int.self, forKey: .totalSearches) ?? 0
        uniqueJobsFound = try container.decodeIfPresent(Int.self, forKey: .uniqueJobsFound) ?? 0
        localJobsCount = try container.decodeIfPresent(Int.self, forKey: .localJobsCount) ?? 0
        nationalJobsCount = try container.decodeIfPresent(Int.self, forKey: .nationalJobsCount) ?? 0
        remoteJobsCount = try container.decodeIfPresent(Int.self, forKey: .remoteJobsCount) ?? 0
        viewedJobsCount = try container.decodeIfPresent(Int.self, forKey: .viewedJobsCount) ?? 0
        starredJobsCount = try container.decodeIfPresent(Int.self, forKey: .starredJobsCount) ?? 0
        
        // Handle avgJobsPerSearch as either Double, Int, or String
        if let doubleValue = try? container.decode(Double.self, forKey: .avgJobsPerSearch) {
            avgJobsPerSearch = doubleValue
        } else if let intValue = try? container.decode(Int.self, forKey: .avgJobsPerSearch) {
            avgJobsPerSearch = Double(intValue)
        } else if let stringValue = try? container.decode(String.self, forKey: .avgJobsPerSearch),
                  let parsed = Double(stringValue) {
            avgJobsPerSearch = parsed
        } else {
            avgJobsPerSearch = 0.0
        }
    }
    
    // Default empty initializer
    init() {
        self.totalSearches = 0
        self.uniqueJobsFound = 0
        self.localJobsCount = 0
        self.nationalJobsCount = 0
        self.remoteJobsCount = 0
        self.avgJobsPerSearch = 0.0
        self.viewedJobsCount = 0
        self.starredJobsCount = 0
    }
    
    // For previews/testing
    init(totalSearches: Int, uniqueJobsFound: Int, localJobsCount: Int, nationalJobsCount: Int, remoteJobsCount: Int, avgJobsPerSearch: Double, viewedJobsCount: Int, starredJobsCount: Int) {
        self.totalSearches = totalSearches
        self.uniqueJobsFound = uniqueJobsFound
        self.localJobsCount = localJobsCount
        self.nationalJobsCount = nationalJobsCount
        self.remoteJobsCount = remoteJobsCount
        self.avgJobsPerSearch = avgJobsPerSearch
        self.viewedJobsCount = viewedJobsCount
        self.starredJobsCount = starredJobsCount
    }
}

// MARK: - Dashboard Session Summary

/// Summary of a single search session from the dashboard API
/// Backend JSON format:
/// {
///   "search_session_id": "2dc0f0f3-...",
///   "created_at": "2025-11-29T18:52:17.621835+00:00",
///   "title_or_inferred_role": "Scheduler",   // deprecated, use currentRoleTitle/lastSearchTitle
///   "current_role_title": "Co-owner / CFO",  // user's current job from résumé
///   "current_role_company": "Acme Inc",      // user's current company from résumé
///   "last_search_title": "Accounting Specialist", // the search intent/inferred role
///   "total_jobs": 81,
///   "local_count": 10,
///   "national_count": 60,
///   "remote_count": 11,
///   "status": "completed",
///   "view_token": "HKWiNZBSwLAmSzLeo0eZ0Ych"
/// }
struct DashboardSessionSummary: Identifiable, Decodable {
    let id: String
    let title: String?  // Deprecated: use currentRoleTitle or lastSearchTitle
    let createdAt: Date
    let totalJobs: Int
    let localCount: Int
    let nationalCount: Int
    let remoteCount: Int
    let status: String?
    let viewToken: String?
    
    // NEW: Semantic labels from backend
    let currentRoleTitle: String?   // User's current job title from résumé
    let currentRoleCompany: String? // User's current company from résumé
    let lastSearchTitle: String?    // The search intent / inferred target role
    
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
        // New fields
        case currentRoleTitle = "current_role_title"
        case currentRoleCompany = "current_role_company"
        case lastSearchTitle = "last_search_title"
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
        
        // New fields
        currentRoleTitle = try container.decodeIfPresent(String.self, forKey: .currentRoleTitle)
        currentRoleCompany = try container.decodeIfPresent(String.self, forKey: .currentRoleCompany)
        lastSearchTitle = try container.decodeIfPresent(String.self, forKey: .lastSearchTitle)
        
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
    
    /// Primary display: current role title from résumé, or fallback to legacy title
    var displayTitle: String {
        if let role = currentRoleTitle, !role.isEmpty {
            return role
        }
        if let title = title, !title.isEmpty {
            return title
        }
        return "Search #\(id.prefix(8))"
    }
    
    /// Secondary display: the search intent (what jobs they're looking for)
    var searchIntentTitle: String {
        if let search = lastSearchTitle, !search.isEmpty {
            return search
        }
        if let title = title, !title.isEmpty {
            return title
        }
        return "Job Search"
    }
    
    /// Formatted subtitle for dashboard cards
    var dashboardSubtitle: String {
        let searchTitle = searchIntentTitle
        let matches = totalJobs
        let timeAgo = formattedDate
        return "Last search: \(searchTitle) • \(matches) matches • \(timeAgo)"
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
    
    init(
        id: String,
        title: String?,
        createdAt: Date,
        totalJobs: Int,
        localCount: Int,
        nationalCount: Int,
        remoteCount: Int,
        status: String? = "completed",
        viewToken: String?,
        currentRoleTitle: String? = nil,
        currentRoleCompany: String? = nil,
        lastSearchTitle: String? = nil
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.totalJobs = totalJobs
        self.localCount = localCount
        self.nationalCount = nationalCount
        self.remoteCount = remoteCount
        self.status = status
        self.viewToken = viewToken
        self.currentRoleTitle = currentRoleTitle
        self.currentRoleCompany = currentRoleCompany
        self.lastSearchTitle = lastSearchTitle
    }
}

// MARK: - Sample Data

extension DashboardAPIResponse {
    static let sample = DashboardAPIResponse(
        summary: DashboardSummaryMetrics(
            totalSearches: 12,
            uniqueJobsFound: 487,
            localJobsCount: 45,
            nationalJobsCount: 320,
            remoteJobsCount: 122,
            avgJobsPerSearch: 40.6,
            viewedJobsCount: 28,
            starredJobsCount: 5
        ),
        recentSessions: DashboardSessionSummary.samples,
        recentStarredJobs: DashboardSavedJob.samples
    )
    
    static let empty = DashboardAPIResponse(
        summary: DashboardSummaryMetrics(),
        recentSessions: [],
        recentStarredJobs: []
    )
}

extension DashboardSavedJob {
    static let samples: [DashboardSavedJob] = [
        DashboardSavedJob(
            id: "job_1",
            title: "Senior iOS Developer",
            company: "Apple Inc.",
            location: "Cupertino, CA",
            jobUrl: "https://example.com/job1"
        ),
        DashboardSavedJob(
            id: "job_2",
            title: "Swift Engineer",
            company: "Spotify",
            location: "Remote",
            jobUrl: "https://example.com/job2"
        )
    ]
}

extension DashboardSessionSummary {
    static let samples: [DashboardSessionSummary] = [
        DashboardSessionSummary(
            id: "session_1",
            title: "Chief Financial Officer",  // Legacy fallback
            createdAt: Date().addingTimeInterval(-2400),
            totalJobs: 95,
            localCount: 15,
            nationalCount: 62,
            remoteCount: 18,
            status: "completed",
            viewToken: "token_abc123",
            currentRoleTitle: "Co-owner / CFO",
            currentRoleCompany: "Sheppard Family Corporation",
            lastSearchTitle: "Accounting Specialist"
        ),
        DashboardSessionSummary(
            id: "session_2",
            title: "Senior iOS Developer",  // Legacy fallback
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

