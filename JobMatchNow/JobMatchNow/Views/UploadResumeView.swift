import SwiftUI
import UniformTypeIdentifiers

struct UploadResumeView: View {
    @State private var selectedFileName: String? = nil
    @State private var isDocumentPickerPresented = false
    @State private var isLoading = false
    @State private var navigateToPipeline = false

    // Computed property to check if analyze button should be enabled
    var canAnalyze: Bool {
        selectedFileName != nil && !isLoading
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
                    isDocumentPickerPresented = true
                }) {
                    Label("Choose File", systemImage: "doc.badge.plus")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
                .disabled(isLoading)
            }
            .padding(.horizontal)

            Spacer()

            // Analyze button
            Button(action: {
                analyzeResume()
            }) {
                if isLoading {
                    HStack(spacing: 10) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                        Text("Analyzing...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(12)
                } else {
                    Text("Analyze My Résumé")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(canAnalyze ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
            }
            .disabled(!canAnalyze)
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToPipeline) {
            PipelineLoadingView()
        }
        .sheet(isPresented: $isDocumentPickerPresented) {
            DocumentPicker(selectedFileName: $selectedFileName)
        }
    }

    private func analyzeResume() {
        // Navigate to pipeline loading view
        navigateToPipeline = true
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

// Document picker wrapper
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFileName: String?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Configure for PDF and document files
        // Using permissive content types to ensure PDFs can be selected
        let types: [UTType] = [.pdf, .item]

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = context.coordinator
        picker.shouldShowFileExtensions = true
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("Document picker delegate called with \(urls.count) URL(s)")
            guard let url = urls.first else {
                print("No URL found in picker result")
                return
            }

            print("Picked file: \(url)")
            print("File name: \(url.lastPathComponent)")

            // Extract just the file name
            parent.selectedFileName = url.lastPathComponent
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker was cancelled")
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        UploadResumeView()
    }
}