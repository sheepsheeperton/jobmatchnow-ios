import Foundation
import UniformTypeIdentifiers

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
    let isRemote: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case job_id
        case title
        case company_name
        case location
        case posted_at
        case job_url
        case source_query
        case category
        case isRemote = "is_remote"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        job_id = try container.decode(String.self, forKey: .job_id)
        title = try container.decode(String.self, forKey: .title)
        company_name = try container.decode(String.self, forKey: .company_name)
        location = try container.decode(String.self, forKey: .location)
        posted_at = try container.decodeIfPresent(String.self, forKey: .posted_at)
        job_url = try container.decodeIfPresent(String.self, forKey: .job_url)
        source_query = try container.decodeIfPresent(String.self, forKey: .source_query)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        isRemote = try container.decodeIfPresent(Bool.self, forKey: .isRemote) ?? false
    }
    
    // Initializer for previews/testing
    init(id: String, job_id: String, title: String, company_name: String, location: String, posted_at: String?, job_url: String?, source_query: String?, category: String?, isRemote: Bool = false) {
        self.id = id
        self.job_id = job_id
        self.title = title
        self.company_name = company_name
        self.location = location
        self.posted_at = posted_at
        self.job_url = job_url
        self.source_query = source_query
        self.category = category
        self.isRemote = isRemote
    }
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

    private let baseURL = "https://www.jobmatchnow.ai"
    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Helper: Get MIME Type for File

    private func getMimeType(for fileURL: URL) -> String {
        print("[APIService] Detecting MIME type for:", fileURL.lastPathComponent)

        // Try to get system-provided content type
        if let resourceValues = try? fileURL.resourceValues(forKeys: [.contentTypeKey]),
           let contentType = resourceValues.contentType,
           let mimeType = contentType.preferredMIMEType {
            print("[APIService] System-detected MIME type:", mimeType)
            return mimeType
        }

        // Fallback to extension-based detection
        let pathExtension = fileURL.pathExtension.lowercased()
        let mimeType: String

        switch pathExtension {
        case "pdf":
            mimeType = "application/pdf"
        case "docx":
            mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "doc":
            mimeType = "application/msword"
        case "png":
            mimeType = "image/png"
        case "jpg", "jpeg":
            mimeType = "image/jpeg"
        case "txt":
            mimeType = "text/plain"
        case "rtf":
            mimeType = "application/rtf"
        default:
            mimeType = "application/octet-stream"
        }

        print("[APIService] Extension-based MIME type:", mimeType)
        return mimeType
    }

    // MARK: - 1. Upload Resume (Improved with MIME detection)

    func uploadResume(fileURL: URL) async throws -> String {
        print("========================================")
        print("[APIService] RESUME UPLOAD START")
        print("========================================")
        print("[APIService] File URL:", fileURL)
        print("[APIService] File name:", fileURL.lastPathComponent)
        print("[APIService] Timestamp:", Date())

        guard let url = URL(string: "\(baseURL)/api/resume") else {
            throw APIError.invalidURL
        }

        // Check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("[APIService] ERROR: File does not exist at path:", fileURL.path)
            throw APIError.fileNotFound
        }

        print("[APIService] File exists, reading data...")

        // Read file data
        let fileData: Data
        do {
            fileData = try Data(contentsOf: fileURL)
            print("[APIService] File data read successfully, size:", fileData.count, "bytes")
        } catch {
            print("[APIService] ERROR: Failed to read file data:", error)
            throw APIError.fileReadError
        }

        // Detect MIME type
        let mimeType = getMimeType(for: fileURL)
        print("[APIService] Using MIME type for upload:", mimeType)

        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add file field with correct MIME type
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        print("[APIService] ----------------------------------------")
        print("[APIService] REQUEST DETAILS:")
        print("[APIService] URL:", url.absoluteString)
        print("[APIService] Method:", request.httpMethod ?? "nil")
        print("[APIService] Content-Type: multipart/form-data; boundary=\(boundary)")
        print("[APIService] Body size:", body.count, "bytes")
        print("[APIService] File MIME type in multipart:", mimeType)
        print("[APIService] Timeout interval:", request.timeoutInterval, "seconds")
        print("[APIService] ----------------------------------------")

        // Perform request
        let (data, response): (Data, URLResponse)
        let requestStartTime = Date()

        do {
            print("[APIService] Sending request at:", requestStartTime)
            (data, response) = try await session.data(for: request)
            let requestDuration = Date().timeIntervalSince(requestStartTime)
            print("[APIService] Request completed in:", String(format: "%.2f", requestDuration), "seconds")
        } catch let error as URLError {
            let requestDuration = Date().timeIntervalSince(requestStartTime)
            print("[APIService] ========================================")
            print("[APIService] NETWORK ERROR after", String(format: "%.2f", requestDuration), "seconds")
            print("[APIService] URLError Code:", error.code.rawValue)
            print("[APIService] Error Description:", error.localizedDescription)

            // Diagnose specific error types
            switch error.code {
            case .timedOut:
                print("[APIService] ERROR TYPE: Request Timeout")
                print("[APIService] The server did not respond within the timeout interval")
            case .cannotFindHost:
                print("[APIService] ERROR TYPE: DNS Failure")
                print("[APIService] Cannot resolve host:", baseURL)
            case .cannotConnectToHost:
                print("[APIService] ERROR TYPE: Connection Failed")
                print("[APIService] Cannot establish connection to host")
            case .networkConnectionLost:
                print("[APIService] ERROR TYPE: Connection Lost")
                print("[APIService] Network connection was lost during request")
            case .dnsLookupFailed:
                print("[APIService] ERROR TYPE: DNS Lookup Failed")
            case .httpTooManyRedirects:
                print("[APIService] ERROR TYPE: Too Many Redirects")
            case .secureConnectionFailed:
                print("[APIService] ERROR TYPE: TLS/SSL Error")
                print("[APIService] Failed to establish secure connection")
            case .serverCertificateUntrusted:
                print("[APIService] ERROR TYPE: Certificate Error")
                print("[APIService] Server certificate is not trusted")
            case .notConnectedToInternet:
                print("[APIService] ERROR TYPE: No Internet Connection")
            default:
                print("[APIService] ERROR TYPE: Other URLError")
            }

            print("[APIService] ========================================")
            throw APIError.networkError(error)
        } catch {
            let requestDuration = Date().timeIntervalSince(requestStartTime)
            print("[APIService] ========================================")
            print("[APIService] UNEXPECTED ERROR after", String(format: "%.2f", requestDuration), "seconds")
            print("[APIService] Error Type:", type(of: error))
            print("[APIService] Error:", error)
            print("[APIService] ========================================")
            throw APIError.networkError(error)
        }

        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[APIService] ERROR: Invalid response type (not HTTPURLResponse)")
            throw APIError.invalidResponse
        }

        print("[APIService] ========================================")
        print("[APIService] RESPONSE RECEIVED")
        print("[APIService] HTTP Status Code:", httpResponse.statusCode)
        print("[APIService] HTTP Status:", HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))

        // Log response headers
        print("[APIService] Response Headers:")
        for (key, value) in httpResponse.allHeaderFields {
            print("[APIService]   \(key): \(value)")
        }

        // Log response body
        print("[APIService] Response Body Size:", data.count, "bytes")
        if let responseString = String(data: data, encoding: .utf8) {
            print("[APIService] Response Body (as string):")
            print("[APIService]", responseString)
        } else {
            print("[APIService] Response Body: (unable to decode as UTF-8)")
            print("[APIService] Raw bytes (first 100):", data.prefix(100))
        }
        print("[APIService] ========================================")

        // Handle error status codes
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("[APIService] ERROR: HTTP Error")
            print("[APIService] Status Code:", httpResponse.statusCode)
            print("[APIService] Error Message:", errorMessage)
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        // Decode response
        struct UploadResponse: Decodable {
            let user_search_id: String
            let view_token: String
            let search_session_id: String
        }

        let uploadResponse: UploadResponse
        do {
            uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
            print("[APIService] SUCCESS: Response decoded successfully")
            print("[APIService] Received user_search_id:", uploadResponse.user_search_id)
            print("[APIService] Received view_token:", uploadResponse.view_token)
            print("[APIService] Received search_session_id:", uploadResponse.search_session_id)
        } catch {
            print("[APIService] ERROR: Failed to decode JSON response")
            print("[APIService] Decoding error:", error)
            if let responseString = String(data: data, encoding: .utf8) {
                print("[APIService] Raw response that failed to decode:", responseString)
            }
            throw APIError.decodingError(error)
        }

        print("[APIService] ========================================")
        print("[APIService] RESUME UPLOAD SUCCESS")
        print("[APIService] ========================================")

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

        print("DEBUG: Session status response - Status code:", httpResponse.statusCode, "URL:", url)

        // Log raw response body
        if let responseBody = String(data: data, encoding: .utf8) {
            let preview = responseBody.prefix(200)
            print("DEBUG: Session status raw response:", preview)
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
            print("DEBUG: Failed to decode session status:", error)
            throw APIError.decodingError(error)
        }

        print("DEBUG: Session status decoded - status:", sessionStatus.status ?? "nil")

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

        print("DEBUG: Get jobs response - Status code:", httpResponse.statusCode, "URL:", url)

        // Log raw response body
        if let responseBody = String(data: data, encoding: .utf8) {
            let preview = responseBody.prefix(500)
            print("DEBUG: Get jobs raw response:", preview)
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
            print("DEBUG: Failed to decode jobs:", error)
            throw APIError.decodingError(error)
        }

        print("DEBUG: Successfully decoded \(jobs.count) jobs")

        return jobs
    }
    
    // MARK: - 4. Get Dashboard Summary
    
    /// Fetches the user's dashboard summary including metrics and recent sessions
    /// Endpoint: GET /api/me/dashboard
    func getDashboard() async throws -> DashboardSummary {
        guard let url = URL(string: "\(baseURL)/api/me/dashboard") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("[APIService] Fetching dashboard from:", url)
        
        // Perform request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("[APIService] Dashboard network error:", error)
            throw APIError.networkError(error)
        }
        
        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("[APIService] Dashboard response - Status code:", httpResponse.statusCode)
        
        // Log raw response body for debugging
        if let responseBody = String(data: data, encoding: .utf8) {
            let preview = responseBody.prefix(500)
            print("[APIService] Dashboard raw response:", preview)
        }
        
        // Handle error status codes
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        // Decode response
        let summary: DashboardSummary
        do {
            summary = try JSONDecoder().decode(DashboardSummary.self, from: data)
        } catch {
            print("[APIService] Failed to decode dashboard:", error)
            throw APIError.decodingError(error)
        }
        
        print("[APIService] Dashboard decoded - \(summary.totalSearches) searches, \(summary.totalJobsFound) jobs, \(summary.recentSessions.count) recent sessions")
        
        return summary
    }
    
    // MARK: - 5. Get Job Explanation
    
    /// Fetches an AI-generated explanation of why a job matches the user's résumé
    /// Endpoint: POST /api/jobs/explanation
    func getJobExplanation(jobId: String, viewToken: String) async throws -> JobExplanation {
        guard let url = URL(string: "\(baseURL)/api/jobs/explanation") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Encode request body
        let requestBody = ExplanationRequest(jobId: jobId, viewToken: viewToken)
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("[APIService] Failed to encode explanation request:", error)
            throw APIError.decodingError(error)
        }
        
        print("[APIService] Fetching explanation for job \(jobId) with token \(viewToken.prefix(8))...")
        
        // Perform request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("[APIService] Explanation network error:", error)
            throw APIError.networkError(error)
        }
        
        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("[APIService] Explanation response - Status code:", httpResponse.statusCode)
        
        // Log raw response body for debugging
        if let responseBody = String(data: data, encoding: .utf8) {
            let preview = responseBody.prefix(300)
            print("[APIService] Explanation raw response:", preview)
        }
        
        // Handle error status codes
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        // Decode response
        let explanation: JobExplanation
        do {
            explanation = try JSONDecoder().decode(JobExplanation.self, from: data)
        } catch {
            print("[APIService] Failed to decode explanation:", error)
            throw APIError.decodingError(error)
        }
        
        print("[APIService] Explanation decoded - \(explanation.bullets.count) bullet points")
        
        return explanation
    }
}
