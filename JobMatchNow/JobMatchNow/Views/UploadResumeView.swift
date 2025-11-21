import SwiftUI
import UniformTypeIdentifiers

struct UploadResumeView: View {
    @State private var isImporterPresented = false
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
                    print("DEBUG: Choose File button pressed")
                    isImporterPresented = true
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
            isPresented: $isImporterPresented,
            allowedContentTypes: [
                .pdf,
                UTType(filenameExtension: "docx") ?? .data,
                UTType(filenameExtension: "doc") ?? .data,
                .plainText,
                .rtf,
                .data
            ],
            allowsMultipleSelection: false
        ) { result in
            print("DEBUG: File picker completion handler called")

            switch result {
            case .success(let urls):
                print("DEBUG: File picker success with \(urls.count) URLs")

                guard let url = urls.first else {
                    print("DEBUG: No URL in urls array")
                    return
                }

                print("DEBUG: Selected file URL:", url)
                print("DEBUG: File name:", url.lastPathComponent)
                print("DEBUG: File path:", url.path)
                print("DEBUG: Is file URL:", url.isFileURL)

                // Try to determine MIME type
                if let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey]),
                   let contentType = resourceValues.contentType {
                    print("DEBUG: Content type:", contentType.identifier)
                    print("DEBUG: Preferred MIME type:", contentType.preferredMIMEType ?? "unknown")
                } else {
                    print("DEBUG: Could not determine content type")
                }

                // Update UI state
                selectedFileURL = url
                selectedFileName = url.lastPathComponent

                print("DEBUG: File selected, triggering automatic upload")

                // Automatically trigger upload after file selection
                uploadSelectedFile(url)

            case .failure(let error):
                print("DEBUG: File picker error:", error.localizedDescription)
                errorMessage = "Failed to select file: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }

    private func analyzeResume() {
        print("DEBUG: analyzeResume() called from Analyze button")
        guard let fileURL = selectedFileURL else {
            print("DEBUG: No file selected")
            return
        }

        uploadSelectedFile(fileURL)
    }

    private func uploadSelectedFile(_ fileURL: URL) {
        print("DEBUG: uploadSelectedFile() called with URL:", fileURL)

        guard !isUploading else {
            print("DEBUG: Upload already in progress, ignoring")
            return
        }

        isUploading = true
        print("DEBUG: Set isUploading = true")

        Task {
            // Start accessing security-scoped resource
            print("DEBUG: Attempting to access security-scoped resource")
            let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
            print("DEBUG: Security-scoped access granted:", didStartAccessing)

            defer {
                // Always stop accessing security-scoped resource
                if didStartAccessing {
                    print("DEBUG: Stopping security-scoped resource access")
                    fileURL.stopAccessingSecurityScopedResource()
                }

                // Reset uploading state
                print("DEBUG: Setting isUploading = false")
                isUploading = false
            }

            do {
                // Verify file exists and is readable
                let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
                print("DEBUG: File exists at path:", fileExists)

                if fileExists, let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path) {
                    let fileSize = attributes[.size] as? Int64 ?? 0
                    print("DEBUG: File size:", fileSize, "bytes")
                }

                print("DEBUG: Starting API upload call")
                // Call the real API
                let token = try await APIService.shared.uploadResume(fileURL: fileURL)

                print("DEBUG: Upload completed successfully! Received viewToken:", token)

                // On success: capture token and navigate
                await MainActor.run {
                    print("DEBUG: Setting viewToken and triggering navigation")
                    viewToken = token
                    navigateToPipeline = true
                }
            } catch {
                // On failure: show error alert
                print("DEBUG: Upload failed with error:", error.localizedDescription)
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }

    private func useSampleResume() {
        print("DEBUG: useSampleResume button pressed")

        // Get bundled sample resume URL
        guard let sampleURL = AppResources.sampleResumeURL() else {
            print("DEBUG: Failed to get sample resume URL from bundle")
            errorMessage = "Sample resume not found in app bundle"
            showErrorAlert = true
            return
        }

        print("DEBUG: Using bundled sample resume at:", sampleURL)

        // Update UI to show selected file
        selectedFileURL = sampleURL
        selectedFileName = "SampleResume.pdf"

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
