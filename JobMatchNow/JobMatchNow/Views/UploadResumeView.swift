import SwiftUI
import UniformTypeIdentifiers

struct UploadResumeView: View {
    @State private var showingFilePicker = false
    @State private var navigateToPipeline = false
    @State private var viewToken: String? = nil
    @State private var isUploading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

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

                // Status indicator
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
                    showingFilePicker = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.badge.arrow.up")
                            .font(.title3)
                        Text("Choose Your Résumé")
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

                #if DEBUG
                // Test button for simulator - only shows in debug builds
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil ||
                   UIDevice.current.userInterfaceIdiom == .pad ||
                   UIDevice.current.userInterfaceIdiom == .phone {
                    Button(action: {
                        uploadTestResume()
                    }) {
                        Text("Test with Sample (Dev Only)")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .disabled(isUploading)
                    .padding(.top, 8)
                }
                #endif
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
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [
                .pdf,
                .png,
                .jpeg,
                UTType(filenameExtension: "docx") ?? .data,
                UTType(filenameExtension: "doc") ?? .data
            ]
        ) { result in
            handleFileSelection(result)
        }
    }

    private func handleFileSelection(_ result: Result<URL, Error>) {
        print("[UploadResumeView] File selection result: \(result)")

        switch result {
        case .success(let fileURL):
            print("[UploadResumeView] File selected: \(fileURL.lastPathComponent)")
            uploadFile(fileURL)

        case .failure(let error):
            print("[UploadResumeView] File selection failed: \(error.localizedDescription)")
            // Only show error if user didn't cancel
            if (error as NSError).code != -128 { // User cancelled
                errorMessage = "Failed to select file. Please try again."
                showErrorAlert = true
            }
        }
    }

    private func uploadFile(_ fileURL: URL) {
        print("[UploadResumeView] Starting upload for file: \(fileURL)")

        guard !isUploading else {
            print("[UploadResumeView] Upload already in progress")
            return
        }

        isUploading = true

        Task {
            // Start accessing security-scoped resource
            let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
            print("[UploadResumeView] Security-scoped access: \(didStartAccessing)")

            defer {
                if didStartAccessing {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }

            do {
                // Log file info
                if let resourceValues = try? fileURL.resourceValues(forKeys: [.contentTypeKey, .fileSizeKey]) {
                    if let contentType = resourceValues.contentType {
                        print("[UploadResumeView] Content type: \(contentType.identifier)")
                        print("[UploadResumeView] MIME type: \(contentType.preferredMIMEType ?? "unknown")")
                    }
                    if let fileSize = resourceValues.fileSize {
                        print("[UploadResumeView] File size: \(fileSize) bytes")
                    }
                }

                // Upload to API
                print("[UploadResumeView] Calling API upload...")
                let token = try await APIService.shared.uploadResume(fileURL: fileURL)

                print("[UploadResumeView] Upload successful, received token: \(token)")

                // Navigate to pipeline
                await MainActor.run {
                    viewToken = token
                    navigateToPipeline = true
                    isUploading = false
                }

            } catch let error as APIError {
                print("[UploadResumeView] API error: \(error)")
                await MainActor.run {
                    isUploading = false
                    errorMessage = getErrorMessage(for: error)
                    showErrorAlert = true
                }
            } catch {
                print("[UploadResumeView] Unexpected error: \(error)")
                await MainActor.run {
                    isUploading = false
                    errorMessage = "We couldn't process your résumé. Please try again."
                    showErrorAlert = true
                }
            }
        }
    }

    #if DEBUG
    private func uploadTestResume() {
        print("[UploadResumeView - DEBUG] Test button pressed")

        // Try to use bundled sample if available
        if let sampleURL = Bundle.main.url(forResource: "SampleResume", withExtension: "pdf") {
            print("[UploadResumeView - DEBUG] Using bundled SampleResume.pdf")
            uploadFile(sampleURL)
        } else {
            // Create a temporary test file if no bundle resource
            print("[UploadResumeView - DEBUG] No bundled sample, creating test file")

            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test-resume.pdf")
            let testData = Data("Test Resume Content".utf8)

            do {
                try testData.write(to: tempURL)
                uploadFile(tempURL)
            } catch {
                print("[UploadResumeView - DEBUG] Failed to create test file: \(error)")
                errorMessage = "Test file creation failed (Dev mode)"
                showErrorAlert = true
            }
        }
    }
    #endif

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