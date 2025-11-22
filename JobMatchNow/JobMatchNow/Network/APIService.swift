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
        print("[APIService] uploadResume() called")
        print("[APIService] File URL:", fileURL)
        print("[APIService] File name:", fileURL.lastPathComponent)

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

        print("[APIService] Sending POST request to:", url)
        print("[APIService] Request Content-Type: multipart/form-data; boundary=\(boundary)")
        print("[APIService] File Content-Type in multipart:", mimeType)

        // Perform request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("[APIService] ERROR: Network request failed:", error)
            throw APIError.networkError(error)
        }

        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[APIService] ERROR: Invalid response type")
            throw APIError.invalidResponse
        }

        print("[APIService] Response status code:", httpResponse.statusCode)

        // Log response body
        if let responseString = String(data: data, encoding: .utf8) {
            print("[APIService] Response body:", responseString)
        }

        // Handle error status codes
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("[APIService] ERROR: HTTP \(httpResponse.statusCode) - \(errorMessage)")
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        // Decode response
        struct UploadResponse: Decodable {
            let view_token: String
        }

        let uploadResponse: UploadResponse
        do {
            uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
            print("[APIService] Successfully decoded response")
            print("[APIService] Received view_token:", uploadResponse.view_token)
        } catch {
            print("[APIService] ERROR: Failed to decode response:", error)
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
}
