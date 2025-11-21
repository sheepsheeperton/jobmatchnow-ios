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
            allowedContentTypes: [.pdf, .data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                selectedFileURL = url
                selectedFileName = url.lastPathComponent
                print("Picked file URL:", url)
                print("File name:", url.lastPathComponent)
            case .failure(let error):
                print("File import error:", error)
            }
        }
    }

    private func analyzeResume() {
        guard let fileURL = selectedFileURL else { return }

        isUploading = true

        Task {
            // Start accessing security-scoped resource
            let didStartAccessing = fileURL.startAccessingSecurityScopedResource()

            defer {
                // Always stop accessing security-scoped resource
                if didStartAccessing {
                    fileURL.stopAccessingSecurityScopedResource()
                }

                // Reset uploading state
                isUploading = false
            }

            do {
                // Call the real API
                let token = try await APIService.shared.uploadResume(fileURL: fileURL)

                // On success: capture token and navigate
                await MainActor.run {
                    viewToken = token
                    navigateToPipeline = true
                }
            } catch {
                // On failure: show error alert
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

        // Upload using real backend pipeline
        isUploading = true

        Task {
            defer {
                isUploading = false
            }

            do {
                print("DEBUG: Uploading bundled sample resume to backend...")
                // Call the real API with bundled resume
                let token = try await APIService.shared.uploadResume(fileURL: sampleURL)

                print("DEBUG: Sample resume upload successful! viewToken:", token)

                // On success: capture token and navigate
                await MainActor.run {
                    viewToken = token
                    navigateToPipeline = true
                }
            } catch {
                // On failure: show error alert
                print("DEBUG: Sample resume upload failed:", error.localizedDescription)
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
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
