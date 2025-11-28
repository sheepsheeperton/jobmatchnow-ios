import SwiftUI
import UniformTypeIdentifiers

// MARK: - UIDocumentPicker Wrapper
/// A UIViewControllerRepresentable wrapper for UIDocumentPickerViewController.
/// More reliable than SwiftUI's .fileImporter in the iOS Simulator.
struct DocumentPicker: UIViewControllerRepresentable {
    let contentTypes: [UTType]
    let onPicked: (URL) -> Void
    let onCancelled: () -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        print("[DocumentPicker] Creating UIDocumentPickerViewController")
        // Use asCopy: false for better simulator compatibility
        // Files will be accessed via security-scoped URL
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: false)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true
        print("[DocumentPicker] Picker configured with content types: \(contentTypes.map { $0.identifier })")
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked, onCancelled: onCancelled)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPicked: (URL) -> Void
        let onCancelled: () -> Void
        
        init(onPicked: @escaping (URL) -> Void, onCancelled: @escaping () -> Void) {
            self.onPicked = onPicked
            self.onCancelled = onCancelled
            super.init()
            print("[DocumentPicker.Coordinator] Coordinator initialized")
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("[DocumentPicker] documentPicker didPickDocumentsAt called")
            print("[DocumentPicker] URLs received: \(urls)")
            
            guard let url = urls.first else {
                print("[DocumentPicker] No URL in selection, treating as cancellation")
                onCancelled()
                return
            }
            
            print("[DocumentPicker] Selected file: \(url.lastPathComponent)")
            print("[DocumentPicker] Full URL: \(url)")
            onPicked(url)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("[DocumentPicker] documentPickerWasCancelled called")
            onCancelled()
        }
    }
}

// MARK: - Upload Resume View
struct UploadResumeView: View {
    // MARK: - State
    @State private var isShowingDocumentPicker = false
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
    /// - Generic data/content types for simulator compatibility
    private static let allowedContentTypes: [UTType] = [
        .pdf,
        .png,
        .jpeg,
        .image,  // Covers all image types
        UTType("com.microsoft.word.doc") ?? .data,
        UTType("org.openxmlformats.wordprocessingml.document") ?? .data,
        .data,   // Fallback for any binary data
        .content // Generic content type
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
                    isShowingDocumentPicker = true
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
        // MARK: - Document Picker Sheet
        .sheet(isPresented: $isShowingDocumentPicker) {
            DocumentPicker(
                contentTypes: Self.allowedContentTypes,
                onPicked: { url in
                    print("[UploadResumeView] Document picker returned URL: \(url)")
                    isShowingDocumentPicker = false
                    uploadFile(url)
                },
                onCancelled: {
                    print("[UploadResumeView] Document picker cancelled")
                    isShowingDocumentPicker = false
                }
            )
            .ignoresSafeArea()
        }
        .onChange(of: isShowingDocumentPicker) { _, newValue in
            print("[UploadResumeView] isShowingDocumentPicker changed to: \(newValue)")
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
