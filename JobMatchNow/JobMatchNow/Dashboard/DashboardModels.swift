//
//  DashboardModels.swift
//  JobMatchNow
//
//  Models for the Dashboard API response.
//

import Foundation

// MARK: - Dashboard API Response

/// Top-level response from GET /api/me/dashboard endpoint
struct DashboardAPIResponse: Decodable {
    let summary: DashboardSummary
    let recentSessions: [DashboardSessionSummary]
    let recentViewedJobs: [DashboardViewedJob]
    
    enum CodingKeys: String, CodingKey {
        case summary
        case recentSessions = "recent_sessions"
        case recentViewedJobs = "recent_viewed_jobs"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        summary = try container.decode(DashboardSummary.self, forKey: .summary)
        recentSessions = try container.decodeIfPresent([DashboardSessionSummary].self, forKey: .recentSessions) ?? []
        recentViewedJobs = try container.decodeIfPresent([DashboardViewedJob].self, forKey: .recentViewedJobs) ?? []
    }
    
    // MARK: - Initializer for previews/testing
    
    init(summary: DashboardSummary, recentSessions: [DashboardSessionSummary], recentViewedJobs: [DashboardViewedJob]) {
        self.summary = summary
        self.recentSessions = recentSessions
        self.recentViewedJobs = recentViewedJobs
    }
}

// MARK: - Dashboard Summary

/// Summary metrics from the dashboard API
/// Backend JSON format:
/// {
///   "total_searches": 1,
///   "unique_jobs_found": 81,
///   "local_jobs_count": 10,
///   "national_jobs_count": 60,
///   "remote_jobs_count": 11,
///   "avg_jobs_per_search": 81,
///   "viewed_jobs_count": 5,
///   "starred_jobs_count": 0
/// }
struct DashboardSummary: Decodable {
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
        
        // Handle avgJobsPerSearch as either Double or String
        if let doubleValue = try? container.decode(Double.self, forKey: .avgJobsPerSearch) {
            avgJobsPerSearch = doubleValue
        } else if let stringValue = try? container.decode(String.self, forKey: .avgJobsPerSearch),
                  let parsed = Double(stringValue) {
            avgJobsPerSearch = parsed
        } else if let intValue = try? container.decode(Int.self, forKey: .avgJobsPerSearch) {
            avgJobsPerSearch = Double(intValue)
        } else {
            avgJobsPerSearch = 0.0
        }
    }
    
    // MARK: - Initializer for previews/testing
    
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
///   "search_session_id": "uuid",
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

// MARK: - Dashboard Viewed Job

/// A recently viewed job from the dashboard API
/// Backend JSON format:
/// {
///   "job_id": "job_123",
///   "title": "Financial Analyst",
///   "company_name": "TD SYNNEX",
///   "location": "Clearwater, FL",
///   "job_url": "https://...",
///   "viewed_at": "2025-11-29T19:00:00+00:00",
///   "view_token": "FpDx1Sp..."
/// }
struct DashboardViewedJob: Identifiable, Decodable {
    let jobId: String
    let title: String
    let companyName: String
    let location: String
    let jobUrl: String?
    let viewedAt: Date
    let viewToken: String?
    
    var id: String { jobId }
    
    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case title
        case companyName = "company_name"
        case location
        case jobUrl = "job_url"
        case viewedAt = "viewed_at"
        case viewToken = "view_token"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        jobId = try container.decode(String.self, forKey: .jobId)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Unknown Position"
        companyName = try container.decodeIfPresent(String.self, forKey: .companyName) ?? "Unknown Company"
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? "Unknown Location"
        jobUrl = try container.decodeIfPresent(String.self, forKey: .jobUrl)
        viewToken = try container.decodeIfPresent(String.self, forKey: .viewToken)
        
        // Parse date from ISO8601 string
        let dateString = try container.decode(String.self, forKey: .viewedAt)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            viewedAt = date
        } else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            viewedAt = formatter.date(from: dateString) ?? Date()
        }
    }
    
    // MARK: - Computed Properties
    
    var formattedViewedAt: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: viewedAt, relativeTo: Date())
    }
    
    var url: URL? {
        guard let jobUrl = jobUrl else { return nil }
        return URL(string: jobUrl)
    }
    
    // MARK: - Initializer for previews/testing
    
    init(jobId: String, title: String, companyName: String, location: String, jobUrl: String?, viewedAt: Date, viewToken: String?) {
        self.jobId = jobId
        self.title = title
        self.companyName = companyName
        self.location = location
        self.jobUrl = jobUrl
        self.viewedAt = viewedAt
        self.viewToken = viewToken
    }
}

// MARK: - Sample Data

extension DashboardAPIResponse {
    static let sample = DashboardAPIResponse(
        summary: .sample,
        recentSessions: DashboardSessionSummary.samples,
        recentViewedJobs: DashboardViewedJob.samples
    )
    
    static let empty = DashboardAPIResponse(
        summary: .empty,
        recentSessions: [],
        recentViewedJobs: []
    )
}

extension DashboardSummary {
    static let sample = DashboardSummary(
        totalSearches: 5,
        uniqueJobsFound: 243,
        localJobsCount: 45,
        nationalJobsCount: 156,
        remoteJobsCount: 42,
        avgJobsPerSearch: 48.6,
        viewedJobsCount: 12,
        starredJobsCount: 3
    )
    
    static let empty = DashboardSummary(
        totalSearches: 0,
        uniqueJobsFound: 0,
        localJobsCount: 0,
        nationalJobsCount: 0,
        remoteJobsCount: 0,
        avgJobsPerSearch: 0.0,
        viewedJobsCount: 0,
        starredJobsCount: 0
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
            viewToken: "token_ghi789"
        )
    ]
}

extension DashboardViewedJob {
    static let samples: [DashboardViewedJob] = [
        DashboardViewedJob(
            jobId: "job_1",
            title: "Financial Analyst",
            companyName: "TD SYNNEX",
            location: "Clearwater, FL",
            jobUrl: "https://example.com/job1",
            viewedAt: Date().addingTimeInterval(-3600),
            viewToken: "token_view1"
        ),
        DashboardViewedJob(
            jobId: "job_2",
            title: "Senior Software Engineer",
            companyName: "Google",
            location: "Mountain View, CA",
            jobUrl: "https://example.com/job2",
            viewedAt: Date().addingTimeInterval(-7200),
            viewToken: "token_view2"
        ),
        DashboardViewedJob(
            jobId: "job_3",
            title: "Product Manager",
            companyName: "Apple",
            location: "Cupertino, CA",
            jobUrl: "https://example.com/job3",
            viewedAt: Date().addingTimeInterval(-86400),
            viewToken: "token_view3"
        )
    ]
}
