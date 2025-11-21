import Foundation

// MARK: - Models

struct SessionStatus: Decodable {
    let status: String?
    let created_at: String?
    let error_message: String?
}

struct Job: Decodable, Identifiable {
    let id: String
    let job_id: String
    let title: String
    let company_name: String
    let location: String
    let posted_at: String?
    let job_url: String?
    let source_query: String?
    let category: String?
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case fileNotFound
    case fileReadError
    case networkError(Error)
    case missingViewToken

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return "HTTP \(statusCode): \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .fileNotFound:
            return "File not found"
        case .fileReadError:
            return "Failed to read file"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .missingViewToken:
            return "Missing view token in response"
        }
    }
}

// MARK: - API Service

class APIService {
    static let shared = APIService()

    private let baseURL = "https://jobmatchnow.ai"
    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - 1. Upload Resume

    func uploadResume(fileURL: URL) async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/resume") else {
            throw APIError.invalidURL
        }

        // Check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw APIError.fileNotFound
        }

        // Read file data
        let fileData: Data
        do {
            fileData = try Data(contentsOf: fileURL)
        } catch {
            throw APIError.fileReadError
        }

        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add file field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        print("DEBUG: Uploading resume to:", url)

        // Perform request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Handle error status codes
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        // Decode response
        struct UploadResponse: Decodable {
            let view_token: String
        }

        let uploadResponse: UploadResponse
        do {
            uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }

        return uploadResponse.view_token
    }

    // MARK: - 2. Get Session Status

    func getSessionStatus(viewToken: String) async throws -> SessionStatus {
        guard var urlComponents = URLComponents(string: "\(baseURL)/api/public/session") else {
            throw APIError.invalidURL
        }

        urlComponents.queryItems = [URLQueryItem(name: "token", value: viewToken)]

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        print("DEBUG: Checking session status at:", url)

        // Perform request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Handle error status codes
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        // Decode response
        let sessionStatus: SessionStatus
        do {
            sessionStatus = try JSONDecoder().decode(SessionStatus.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }

        return sessionStatus
    }

    // MARK: - 3. Get Jobs

    func getJobs(viewToken: String) async throws -> [Job] {
        guard var urlComponents = URLComponents(string: "\(baseURL)/api/public/jobs") else {
            throw APIError.invalidURL
        }

        urlComponents.queryItems = [URLQueryItem(name: "token", value: viewToken)]

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        print("DEBUG: Fetching jobs from:", url)

        // Perform request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Handle error status codes
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        // Decode response
        let jobs: [Job]
        do {
            jobs = try JSONDecoder().decode([Job].self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }

        return jobs
    }
}
