import SwiftUI
import UniformTypeIdentifiers

struct UploadResumeView: View {
    // MARK: - State
    @State private var isShowingFileImporter = false
    @State private var navigateToPipeline = false
    @State private var viewToken: String? = nil
    @State private var isUploading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // MARK: - Allowed Content Types
    /// Supported file types for resume upload:
    /// - PDF documents
    /// - PNG and JPEG images
    /// - Microsoft Word documents (doc and docx)
    private static let allowedContentTypes: [UTType] = [
        .pdf,
        .png,
        .jpeg,
        UTType("com.microsoft.word.doc") ?? .data,
        UTType("org.openxmlformats.wordprocessingml.document") ?? .data
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Top content section
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Text("Upload Your Résumé")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("We'll analyze your skills and match you with relevant job opportunities")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Status indicator when uploading
                if isUploading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.blue)
                        
                        Text("Analyzing your résumé...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 40)
                }
                
                Spacer()
            }
            
            // Bottom button section
            VStack(spacing: 16) {
                // Primary upload button
                Button(action: {
                    print("[UploadResumeView] Upload button pressed")
                    isShowingFileImporter = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.badge.arrow.up")
                            .font(.title3)
                        Text("Choose Résumé File")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isUploading ? Color.gray : Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isUploading)
                
                // Supported formats hint
                Text("Supports PDF, Word, and image files")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToPipeline) {
            if let token = viewToken {
                PipelineLoadingView(viewToken: token)
            }
        }
        .alert("Upload Failed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        // MARK: - File Importer
        // Attached to the root VStack per SwiftUI best practices
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: Self.allowedContentTypes,
            allowsMultipleSelection: false
        ) { result in
            handleFileImporterResult(result)
        }
        .onChange(of: isShowingFileImporter) { _, newValue in
            print("[UploadResumeView] fileImporter isPresented changed to: \(newValue)")
        }
    }
    
    // MARK: - File Importer Result Handler
    private func handleFileImporterResult(_ result: Result<[URL], Error>) {
        print("[UploadResumeView] fileImporter completion called")
        
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else {
                print("[UploadResumeView] fileImporter completion: success but no URL returned")
                return
            }
            print("[UploadResumeView] fileImporter completion: success")
            print("[UploadResumeView] Selected file URL: \(fileURL)")
            uploadFile(fileURL)
            
        case .failure(let error):
            print("[UploadResumeView] fileImporter completion: failure")
            print("[UploadResumeView] Error: \(error.localizedDescription)")
            
            // Check if user cancelled (error code -128 is user cancellation)
            let nsError = error as NSError
            if nsError.domain == NSCocoaErrorDomain && nsError.code == NSUserCancelledError {
                print("[UploadResumeView] User cancelled file selection")
                return
            }
            
            // Show error for actual failures
            errorMessage = "We couldn't open that file. Please try again."
            showErrorAlert = true
        }
    }
    
    // MARK: - Upload File
    private func uploadFile(_ fileURL: URL) {
        print("[UploadResumeView] Starting upload for file: \(fileURL.lastPathComponent)")
        
        guard !isUploading else {
            print("[UploadResumeView] Upload already in progress, ignoring")
            return
        }
        
        isUploading = true
        
        Task {
            // Start accessing security-scoped resource
            let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
            print("[UploadResumeView] Security-scoped access started: \(didStartAccessing)")
            
            defer {
                if didStartAccessing {
                    fileURL.stopAccessingSecurityScopedResource()
                    print("[UploadResumeView] Security-scoped access stopped")
                }
            }
            
            do {
                // Log detailed file information
                logFileInfo(for: fileURL)
                
                // Upload to API using shared service
                print("[UploadResumeView] Calling APIService.uploadResume...")
                let token = try await APIService.shared.uploadResume(fileURL: fileURL)
                
                print("[UploadResumeView] Upload successful!")
                print("[UploadResumeView] Received view_token: \(token)")
                
                // Navigate to pipeline on main thread
                await MainActor.run {
                    viewToken = token
                    isUploading = false
                    print("[UploadResumeView] Navigating to pipeline with viewToken=\(token)")
                    navigateToPipeline = true
                }
                
            } catch let error as APIError {
                print("[UploadResumeView] API error during upload: \(error)")
                await MainActor.run {
                    isUploading = false
                    errorMessage = getErrorMessage(for: error)
                    showErrorAlert = true
                }
            } catch {
                print("[UploadResumeView] Unexpected error during upload: \(error)")
                await MainActor.run {
                    isUploading = false
                    errorMessage = "We couldn't process your résumé. Please try again."
                    showErrorAlert = true
                }
            }
        }
    }
    
    // MARK: - Log File Info
    private func logFileInfo(for fileURL: URL) {
        print("[UploadResumeView] ---- File Details ----")
        print("[UploadResumeView] File URL: \(fileURL)")
        print("[UploadResumeView] File name: \(fileURL.lastPathComponent)")
        
        do {
            let resourceValues = try fileURL.resourceValues(forKeys: [
                .contentTypeKey,
                .fileSizeKey,
                .creationDateKey
            ])
            
            if let fileSize = resourceValues.fileSize {
                print("[UploadResumeView] File size: \(fileSize) bytes")
            }
            
            if let contentType = resourceValues.contentType {
                print("[UploadResumeView] Content type (UTI): \(contentType.identifier)")
                if let mimeType = contentType.preferredMIMEType {
                    print("[UploadResumeView] MIME type: \(mimeType)")
                }
            }
            
            if let creationDate = resourceValues.creationDate {
                print("[UploadResumeView] Created: \(creationDate)")
            }
        } catch {
            print("[UploadResumeView] Could not read file attributes: \(error.localizedDescription)")
        }
        print("[UploadResumeView] ---- End File Details ----")
    }
    
    // MARK: - Error Message Helper
    private func getErrorMessage(for error: APIError) -> String {
        switch error {
        case .fileNotFound, .fileReadError:
            return "We couldn't read the selected file. Please try again."
        case .httpError(let code, _):
            if code == 413 {
                return "The file is too large. Please choose a smaller file."
            } else if code == 400 {
                return "This file format isn't supported. Please use PDF, Word, or image files."
            } else if code >= 500 {
                return "Our servers are having issues. Please try again later."
            }
            return "We couldn't process your résumé. Please try again."
        case .networkError(let underlyingError):
            if let urlError = underlyingError as? URLError {
                switch urlError.code {
                case .timedOut:
                    return "The upload took too long. Please check your connection and try again."
                case .notConnectedToInternet:
                    return "No internet connection. Please check your connection and try again."
                default:
                    break
                }
            }
            return "Connection error. Please check your internet and try again."
        default:
            return "We couldn't process your résumé. Please try again."
        }
    }
}

#Preview {
    NavigationStack {
        UploadResumeView()
    }
}
