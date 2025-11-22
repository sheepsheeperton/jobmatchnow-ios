import SwiftUI
import UniformTypeIdentifiers

struct UploadResumeView: View {
    @State private var showingFilePicker = false
    @State private var selectedFileURL: URL? = nil
    @State private var selectedFileName: String? = nil
    @State private var navigateToPipeline = false
    @State private var viewToken: String? = nil
    @State private var isUploading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    // Computed property to check if analyze button should be enabled
    var canAnalyze: Bool {
        selectedFileURL != nil && !isUploading
    }

    var body: some View {
        VStack(spacing: 24) {
            // Header section
            VStack(spacing: 12) {
                Text("Upload your résumé")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("We'll extract your skills and match you to relevant job listings.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)

            Spacer()

            // File upload section
            VStack(spacing: 20) {
                // File card
                FileCard(fileName: selectedFileName)

                // Choose file button
                Button(action: {
                    print("[UploadResumeView] Choose File button pressed")
                    showingFilePicker = true
                    print("[UploadResumeView] fileImporter presented")
                }) {
                    Label("Choose File", systemImage: "doc.badge.plus")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
                .disabled(isUploading)

                // Debug bypass button
                Button(action: {
                    useSampleResume()
                }) {
                    Label("Use sample résumé (debug)", systemImage: "doc.text.fill")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)

            Spacer()

            // Analyze button
            Button(action: {
                analyzeResume()
            }) {
                HStack {
                    if isUploading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Uploading...")
                    } else {
                        Text("Analyze My Résumé")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(canAnalyze ? Color.blue : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!canAnalyze)
            .padding(.horizontal)
            .padding(.bottom, 30)
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
            print("[UploadResumeView] fileImporter completion: \(result)")

            switch result {
            case .success(let url):
                print("[UploadResumeView] fileImporter completion: success")
                print("[UploadResumeView] Selected URL:", url)
                print("[UploadResumeView] File name:", url.lastPathComponent)

                // Get content type and MIME type
                if let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey]) {
                    if let contentType = resourceValues.contentType {
                        print("[UploadResumeView] Content type identifier:", contentType.identifier)
                        print("[UploadResumeView] MIME type:", contentType.preferredMIMEType ?? "unknown")
                    }
                }

                // Update state
                selectedFileURL = url
                selectedFileName = url.lastPathComponent

                print("[UploadResumeView] Starting upload for selected file...")

                // Trigger upload automatically
                uploadSelectedFile(url)

            case .failure(let error):
                print("[UploadResumeView] fileImporter completion: failure")
                print("[UploadResumeView] Error:", error.localizedDescription)
                errorMessage = "Failed to select file: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }

    private func analyzeResume() {
        print("[UploadResumeView] Analyze button pressed")
        guard let fileURL = selectedFileURL else {
            print("[UploadResumeView] No file selected for analyze")
            return
        }

        uploadSelectedFile(fileURL)
    }

    private func uploadSelectedFile(_ fileURL: URL) {
        print("[UploadResumeView] uploadSelectedFile() called with URL:", fileURL)

        guard !isUploading else {
            print("[UploadResumeView] Upload already in progress, ignoring")
            return
        }

        isUploading = true
        print("[UploadResumeView] Setting isUploading = true")

        Task {
            // Start accessing security-scoped resource
            print("[UploadResumeView] Attempting to access security-scoped resource")
            let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
            print("[UploadResumeView] Security-scoped access granted:", didStartAccessing)

            defer {
                // Always stop accessing security-scoped resource
                if didStartAccessing {
                    print("[UploadResumeView] Stopping security-scoped resource access")
                    fileURL.stopAccessingSecurityScopedResource()
                }

                // Reset uploading state
                print("[UploadResumeView] Setting isUploading = false")
                isUploading = false
            }

            do {
                // Verify file exists and is readable
                let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
                print("[UploadResumeView] File exists at path:", fileExists)

                if fileExists, let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path) {
                    let fileSize = attributes[.size] as? Int64 ?? 0
                    print("[UploadResumeView] File size:", fileSize, "bytes")
                }

                print("[UploadResumeView] Starting API upload call to /api/resume")
                // Call the real API
                let token = try await APIService.shared.uploadResume(fileURL: fileURL)

                print("[UploadResumeView] Upload success! Received viewToken:", token)

                // On success: capture token and navigate
                await MainActor.run {
                    print("[UploadResumeView] Navigating to PipelineLoadingView with viewToken=\(token)")
                    viewToken = token
                    navigateToPipeline = true
                }
            } catch {
                // On failure: show error alert
                print("[UploadResumeView] Upload error:", error.localizedDescription)
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }

    private func useSampleResume() {
        print("========================================")
        print("[DEBUG BUTTON] Sample resume button pressed")
        print("========================================")

        // Get bundled sample resume URL
        guard let sampleURL = AppResources.sampleResumeURL() else {
            print("[DEBUG BUTTON] ERROR: Failed to get sample resume URL from bundle")
            errorMessage = "Sample resume not found in app bundle"
            showErrorAlert = true
            return
        }

        print("[DEBUG BUTTON] Found bundled sample resume at:", sampleURL)
        print("[DEBUG BUTTON] File exists:", FileManager.default.fileExists(atPath: sampleURL.path))

        // Update UI to show selected file
        selectedFileURL = sampleURL
        selectedFileName = "SampleResume.pdf"

        print("[DEBUG BUTTON] Calling shared upload function...")
        // Upload using the same upload function
        uploadSelectedFile(sampleURL)
    }
}

// File card component
struct FileCard: View {
    let fileName: String?

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: fileName != nil ? "doc.fill" : "doc")
                .font(.title)
                .foregroundColor(fileName != nil ? .blue : .gray)

            VStack(alignment: .leading, spacing: 4) {
                Text(fileName ?? "No file selected yet")
                    .font(.headline)
                    .foregroundColor(fileName != nil ? .primary : .secondary)

                if fileName != nil {
                    Text("Ready to analyze")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        UploadResumeView()
    }
}
