import Foundation

// MARK: - Search Session Model

/// Represents a past search session from the dashboard
struct SearchSession: Identifiable, Codable {
    let id: String
    let viewToken: String
    let createdAt: Date
    let label: String?
    let totalMatches: Int
    let directMatches: Int
    let adjacentMatches: Int
    let status: String?
    
    // MARK: - Computed Properties
    
    var displayLabel: String {
        if let label = label, !label.isEmpty {
            return label
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
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case viewToken = "view_token"
        case createdAt = "created_at"
        case label
        case totalMatches = "total_matches"
        case directMatches = "direct_matches"
        case adjacentMatches = "adjacent_matches"
        case status
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        viewToken = try container.decode(String.self, forKey: .viewToken)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        totalMatches = try container.decodeIfPresent(Int.self, forKey: .totalMatches) ?? 0
        directMatches = try container.decodeIfPresent(Int.self, forKey: .directMatches) ?? 0
        adjacentMatches = try container.decodeIfPresent(Int.self, forKey: .adjacentMatches) ?? 0
        status = try container.decodeIfPresent(String.self, forKey: .status)
        
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
    
    // MARK: - Initializer for previews/testing
    
    init(id: String, viewToken: String, createdAt: Date, label: String?, totalMatches: Int, directMatches: Int, adjacentMatches: Int, status: String? = "completed") {
        self.id = id
        self.viewToken = viewToken
        self.createdAt = createdAt
        self.label = label
        self.totalMatches = totalMatches
        self.directMatches = directMatches
        self.adjacentMatches = adjacentMatches
        self.status = status
    }
}

// MARK: - Sample Data

extension SearchSession {
    static let samples: [SearchSession] = [
        SearchSession(
            id: "1",
            viewToken: "token_1",
            createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
            label: "Software Engineer",
            totalMatches: 45,
            directMatches: 32,
            adjacentMatches: 13,
            status: "completed"
        ),
        SearchSession(
            id: "2",
            viewToken: "token_2",
            createdAt: Date().addingTimeInterval(-86400), // 1 day ago
            label: "iOS Developer",
            totalMatches: 67,
            directMatches: 41,
            adjacentMatches: 26,
            status: "completed"
        ),
        SearchSession(
            id: "3",
            viewToken: "token_3",
            createdAt: Date().addingTimeInterval(-259200), // 3 days ago
            label: nil,
            totalMatches: 23,
            directMatches: 15,
            adjacentMatches: 8,
            status: "completed"
        )
    ]
}

