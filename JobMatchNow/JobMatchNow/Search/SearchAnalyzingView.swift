import SwiftUI

// MARK: - Search Analyzing View

/// Pipeline loading screen that shows progress while analyzing résumé
struct SearchAnalyzingView: View {
    let viewToken: String
    
    @StateObject private var appState = AppState.shared
    @State private var currentStep = 0
    @State private var navigateToResults = false
    @State private var jobs: [Job] = []
    @State private var pollingTask: Task<Void, Never>?
    @State private var sessionStatus: String?
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    let steps = [
        PipelineStep(icon: "doc.text.magnifyingglass", title: "Parsing your résumé..."),
        PipelineStep(icon: "cpu", title: "Extracting skills..."),
        PipelineStep(icon: "magnifyingglass", title: "Finding job matches..."),
        PipelineStep(icon: "checkmark.circle", title: "Preparing results...")
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            // Header
            VStack(spacing: 12) {
                Text("Analyzing Your Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(ThemeColors.textOnDark)
                    .multilineTextAlignment(.center)
                
                Text("This will only take a moment")
                    .font(.body)
                    .foregroundColor(ThemeColors.textOnDark.opacity(0.7))
            }
            .padding(.top, 60)
            
            Spacer()
            
            // Pipeline steps
            VStack(spacing: 24) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    PipelineStepRow(
                        step: step,
                        status: getStepStatus(for: index)
                    )
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [ThemeColors.wealthDark, ThemeColors.wealthDeep],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .statusBarLightContent()  // Dark background → light status bar
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToResults) {
            SearchResultsView(jobs: jobs, viewToken: viewToken)
        }
        .alert("Processing Failed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            startPolling()
        }
        .onDisappear {
            stopPolling()
        }
    }
    
    private func getStepStatus(for index: Int) -> StepStatus {
        if index < currentStep {
            return .completed
        } else if index == currentStep {
            return .inProgress
        } else {
            return .pending
        }
    }
    
    private func startPolling() {
        print("DEBUG: Starting session status polling with viewToken:", viewToken)
        
        pollingTask = Task {
            while !Task.isCancelled {
                do {
                    print("DEBUG: Polling session status...")
                    let status = try await APIService.shared.getSessionStatus(viewToken: viewToken)
                    
                    print("DEBUG: Received status:", status.status ?? "nil")
                    
                    await MainActor.run {
                        sessionStatus = status.status
                        
                        if currentStep < steps.count - 1 {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    
                    if let statusValue = status.status {
                        if statusValue == "completed" {
                            print("DEBUG: Status completed, fetching jobs")
                            await fetchJobsAndNavigate()
                            break
                        } else if statusValue == "failed" {
                            print("DEBUG: Status failed:", status.error_message ?? "No error message")
                            await MainActor.run {
                                errorMessage = status.error_message ?? "An unknown error occurred"
                                showErrorAlert = true
                            }
                            break
                        }
                    }
                    
                } catch {
                    print("DEBUG: Error polling status:", error.localizedDescription)
                    await MainActor.run {
                        errorMessage = "Failed to check status: \(error.localizedDescription)"
                        showErrorAlert = true
                    }
                    break
                }
                
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }
    
    private func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    private func fetchJobsAndNavigate() async {
        print("DEBUG: fetchJobsAndNavigate called")
        
        do {
            let fetchedJobs = try await APIService.shared.getJobs(viewToken: viewToken)
            
            print("DEBUG: Fetched \(fetchedJobs.count) jobs")
            
            // Calculate category counts
            let directCount = fetchedJobs.filter { $0.category?.lowercased() == "direct" }.count
            let adjacentCount = fetchedJobs.filter { $0.category?.lowercased() == "adjacent" }.count
            
            await MainActor.run {
                withAnimation {
                    currentStep = steps.count
                }
                
                jobs = fetchedJobs
                
                // Save as last search
                let lastSearchInfo = AppState.LastSearchInfo(
                    viewToken: viewToken,
                    date: Date(),
                    totalMatches: fetchedJobs.count,
                    directMatches: directCount,
                    adjacentMatches: adjacentCount,
                    label: fetchedJobs.first?.title // Use first job title as label
                )
                appState.saveLastSearch(lastSearchInfo)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navigateToResults = true
                }
            }
        } catch {
            print("DEBUG: Error fetching jobs:", error.localizedDescription)
            await MainActor.run {
                errorMessage = "Failed to fetch jobs: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
}

// MARK: - Pipeline Step Model

struct PipelineStep {
    let icon: String
    let title: String
}

// MARK: - Step Status

enum StepStatus {
    case pending
    case inProgress
    case completed
}

// MARK: - Pipeline Step Row

struct PipelineStepRow: View {
    let step: PipelineStep
    let status: StepStatus
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 44, height: 44)
                
                if status == .completed {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(ThemeColors.textOnDark)
                } else if status == .inProgress {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: ThemeColors.textOnDark))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: step.icon)
                        .font(.title3)
                        .foregroundColor(ThemeColors.textOnDark.opacity(0.4))
                }
            }
            
            Text(step.title)
                .font(.headline)
                .foregroundColor(status == .pending ? ThemeColors.textOnDark.opacity(0.5) : ThemeColors.textOnDark)
            
            Spacer()
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .completed:
            return ThemeColors.wealthBright.opacity(0.6)
        case .inProgress:
            return ThemeColors.primaryBrand
        case .pending:
            return ThemeColors.textOnDark.opacity(0.15)
        }
    }
}

#Preview {
    NavigationStack {
        SearchAnalyzingView(viewToken: "sample_token")
    }
}
