import SwiftUI
import UniformTypeIdentifiers
import VisionKit

// MARK: - Search Upload View

/// Root view for the Search tab (triadic palette)
struct SearchUploadView: View {
    @StateObject private var appState = AppState.shared
    @State private var isShowingDocumentPicker = false
    @State private var isShowingScanner = false
    @State private var navigateToPipeline = false
    @State private var navigateToLastSearch = false
    @State private var viewToken: String? = nil
    @State private var lastSearchJobs: [Job] = []
    @State private var isLoadingLastSearch = false
    @State private var isUploading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showSettings = false
    
    // MARK: - Allowed Content Types
    private static let allowedContentTypes: [UTType] = [
        .pdf,
        .png,
        .jpeg,
        .image,
        UTType("com.microsoft.word.doc") ?? .data,
        UTType("org.openxmlformats.wordprocessingml.document") ?? .data,
        .data,
        .content
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top content section
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Text("Upload Your Résumé")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ThemeColors.primaryBrand)
                        .multilineTextAlignment(.center)
                    
                    Text("We'll analyze your skills and match you with relevant job opportunities")
                        .font(.body)
                        .foregroundColor(ThemeColors.textSecondaryLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Upload illustration - sand background, purple icon
                ZStack {
                    Circle()
                        .fill(ThemeColors.accentSand)
                        .frame(width: 160, height: 160)
                    
                    Image(systemName: "doc.badge.arrow.up.fill")
                        .font(.system(size: 70))
                        .foregroundColor(ThemeColors.primaryBrand)
                }
                
                // Status indicator when uploading
                if isUploading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(ThemeColors.accentGreen)
                        
                        Text("Analyzing your résumé...")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.textSecondaryLight)
                    }
                    .padding(.vertical, 40)
                }
                
                Spacer()
            }
            
            // Last search card (if available)
            if let lastSearch = appState.lastSearch {
                LastSearchCard(
                    lastSearch: lastSearch,
                    isLoading: isLoadingLastSearch
                ) {
                    loadLastSearchResults(lastSearch)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            
            // Bottom button section
            VStack(spacing: 16) {
                // Primary upload button - green CTA
                Button(action: {
                    print("[SearchUploadView] Upload button pressed")
                    isShowingDocumentPicker = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.badge.arrow.up")
                            .font(.title3)
                        Text("Choose Résumé File")
                            .font(.headline)
                    }
                    .foregroundColor(ThemeColors.textOnDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isUploading ? ThemeColors.softGrey : ThemeColors.accentGreen)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
                .disabled(isUploading)
                
                // Secondary camera button - outlined green
                if DocumentScannerView.isSupported {
                    Button(action: {
                        print("[SearchUploadView] Camera button pressed")
                        isShowingScanner = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.title3)
                            Text("Scan with Camera")
                                .font(.headline)
                        }
                        .foregroundColor(ThemeColors.accentGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(ThemeColors.cardLight)
                        .cornerRadius(Theme.CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                .stroke(ThemeColors.accentGreen, lineWidth: 1.5)
                        )
                    }
                    .disabled(isUploading)
                }
                
                // Supported formats hint
                Text("Supports PDF, Word, and image files")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondaryLight)
                
                #if DEBUG
                // Simulator workaround
                if isRunningInSimulator {
                    Button(action: {
                        print("[SearchUploadView] DEBUG: Using bundled sample resume")
                        uploadBundledSampleResume()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.fill")
                            Text("Use Sample Résumé")
                        }
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.primaryBrand)
                    }
                    .disabled(isUploading)
                    .padding(.top, 8)
                }
                #endif
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(ThemeColors.surfaceLight)
        .statusBarDarkContent()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(ThemeColors.primaryBrand)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToPipeline) {
            if let token = viewToken {
                SearchAnalyzingView(viewToken: token)
            }
        }
        .navigationDestination(isPresented: $navigateToLastSearch) {
            if let lastSearch = appState.lastSearch {
                SearchResultsView(
                    jobs: lastSearchJobs,
                    viewToken: lastSearch.viewToken,
                    source: .historical(sessionId: lastSearch.viewToken)
                )
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .alert("Upload Failed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $isShowingDocumentPicker) {
            DocumentPicker(
                contentTypes: Self.allowedContentTypes,
                onPicked: { url in
                    print("[SearchUploadView] Document picker returned URL: \(url)")
                    isShowingDocumentPicker = false
                    uploadFile(url)
                },
                onCancelled: {
                    print("[SearchUploadView] Document picker cancelled")
                    isShowingDocumentPicker = false
                }
            )
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $isShowingScanner) {
            DocumentScannerView(
                onScan: { image in
                    print("[SearchUploadView] Document scanned, processing image...")
                    isShowingScanner = false
                    handleScannedImage(image)
                },
                onCancel: {
                    print("[SearchUploadView] Scanner cancelled")
                    isShowingScanner = false
                }
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Load Last Search Results
    
    private func loadLastSearchResults(_ lastSearch: AppState.LastSearchInfo) {
        guard !isLoadingLastSearch else {
            print("[SearchUploadView] Already loading last search, ignoring duplicate tap")
            return
        }
        
        print("[SearchUploadView] Loading last search results for viewToken: \(lastSearch.viewToken)")
        isLoadingLastSearch = true
        
        Task {
            do {
                let jobs = try await APIService.shared.getJobs(viewToken: lastSearch.viewToken)
                
                print("[SearchUploadView] Loaded \(jobs.count) jobs from last search")
                
                await MainActor.run {
                    lastSearchJobs = jobs
                    isLoadingLastSearch = false
                    navigateToLastSearch = true
                }
            } catch {
                print("[SearchUploadView] Failed to load last search results: \(error)")
                
                await MainActor.run {
                    isLoadingLastSearch = false
                    errorMessage = "Could not load your last search. Please try again."
                    showErrorAlert = true
                }
            }
        }
    }
    
    // MARK: - Handle Scanned Image
    
    private func handleScannedImage(_ image: UIImage) {
        print("[SearchUploadView] Processing scanned image: \(Int(image.size.width))x\(Int(image.size.height))")
        
        guard !isUploading else {
            print("[SearchUploadView] Upload already in progress, ignoring scanned image")
            return
        }
        
        guard let fileURL = ImageProcessor.prepareForUpload(image) else {
            print("[SearchUploadView] ❌ Failed to process scanned image")
            errorMessage = "Could not process the scanned image. Please try again."
            showErrorAlert = true
            return
        }
        
        print("[SearchUploadView] ✅ Scanned image ready at: \(fileURL.lastPathComponent)")
        uploadFile(fileURL)
    }
    
    // MARK: - Upload File
    
    private func uploadFile(_ fileURL: URL) {
        print("[SearchUploadView] Starting upload for file: \(fileURL.lastPathComponent)")
        
        guard !isUploading else {
            print("[SearchUploadView] Upload already in progress, ignoring")
            return
        }
        
        isUploading = true
        
        Task {
            let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
            
            defer {
                if didStartAccessing {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }
            
            do {
                let token = try await APIService.shared.uploadResume(fileURL: fileURL)
                
                print("[SearchUploadView] Upload successful! Token: \(token)")
                
                await MainActor.run {
                    viewToken = token
                    isUploading = false
                    navigateToPipeline = true
                }
                
            } catch let error as APIError {
                print("[SearchUploadView] API error during upload: \(error)")
                await MainActor.run {
                    isUploading = false
                    errorMessage = getErrorMessage(for: error)
                    showErrorAlert = true
                }
            } catch {
                print("[SearchUploadView] Unexpected error during upload: \(error)")
                await MainActor.run {
                    isUploading = false
                    errorMessage = "We couldn't process your résumé. Please try again."
                    showErrorAlert = true
                }
            }
        }
    }
    
    #if DEBUG
    private var isRunningInSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    private func uploadBundledSampleResume() {
        guard let sampleURL = Bundle.main.url(forResource: "SampleResume", withExtension: "pdf") else {
            print("[SearchUploadView] DEBUG ERROR: SampleResume.pdf not found in bundle")
            errorMessage = "Sample resume not found in app bundle."
            showErrorAlert = true
            return
        }
        print("[SearchUploadView] DEBUG: Found bundled sample at \(sampleURL)")
        uploadFile(sampleURL)
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

// MARK: - Last Search Card (triadic palette)

struct LastSearchCard: View {
    let lastSearch: AppState.LastSearchInfo
    let isLoading: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Last Search")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeColors.textSecondaryLight)
                    
                    Text(displayTitle)
                        .font(.headline)
                        .foregroundColor(ThemeColors.primaryBrand)
                    
                    if let currentRole = lastSearch.currentRoleTitle, !currentRole.isEmpty {
                        Text("Based on your role: \(currentRole)")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.textSecondaryLight)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 12) {
                        Label("\(lastSearch.totalMatches) matches", systemImage: "briefcase")
                        Label(formattedDate, systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondaryLight)
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(ThemeColors.accentGreen)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(ThemeColors.textSecondaryLight)
                }
            }
            .padding()
            .background(ThemeColors.cardLight)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(ThemeColors.borderSubtle, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
    }
    
    private var displayTitle: String {
        if let searchTitle = lastSearch.lastSearchTitle, !searchTitle.isEmpty {
            return searchTitle
        }
        if let label = lastSearch.label, !label.isEmpty {
            return label
        }
        return "Recent search"
    }
    
    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastSearch.date, relativeTo: Date())
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    let contentTypes: [UTType]
    let onPicked: (URL) -> Void
    let onCancelled: () -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: false)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked, onCancelled: onCancelled)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPicked: (URL) -> Void
        let onCancelled: () -> Void
        
        init(onPicked: @escaping (URL) -> Void, onCancelled: @escaping () -> Void) {
            self.onPicked = onPicked
            self.onCancelled = onCancelled
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                onCancelled()
                return
            }
            onPicked(url)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCancelled()
        }
    }
}

#Preview {
    NavigationStack {
        SearchUploadView()
    }
}
