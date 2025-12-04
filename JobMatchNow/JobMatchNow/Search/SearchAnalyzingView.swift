import SwiftUI

// MARK: - Analyzing View State

enum AnalyzingState {
    case analyzing
    case error(message: String)
}

// MARK: - Search Analyzing View

/// Pipeline loading screen (triadic palette)
struct SearchAnalyzingView: View {
    let viewToken: String
    
    @StateObject private var appState = AppState.shared
    @State private var currentStep = 0
    @State private var navigateToResults = false
    @State private var jobs: [Job] = []
    @State private var pollingTask: Task<Void, Never>?
    @State private var sessionStatus: String?
    @State private var viewState: AnalyzingState = .analyzing
    @State private var pollCount = 0
    @Environment(\.dismiss) private var dismiss
    
    // Polling timeout: 90 seconds (45 polls * 2 second interval)
    private let maxPollCount = 45
    
    let steps = [
        PipelineStep(icon: "doc.text.magnifyingglass", title: "Parsing your résumé..."),
        PipelineStep(icon: "cpu", title: "Extracting skills..."),
        PipelineStep(icon: "magnifyingglass", title: "Finding job matches..."),
        PipelineStep(icon: "checkmark.circle", title: "Preparing results...")
    ]
    
    var body: some View {
        ZStack {
            // Dark gradient background (purple family)
            ThemeColors.loadingGradient
                .ignoresSafeArea()
            
            switch viewState {
            case .analyzing:
                analyzingContent
                
            case .error(let message):
                errorContent(message: message)
            }
        }
        .statusBarLightContent()
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToResults) {
            SearchResultsView(jobs: jobs, viewToken: viewToken)
        }
        .onAppear {
            startPolling()
        }
        .onDisappear {
            stopPolling()
        }
    }
    
    // MARK: - Analyzing Content
    
    private var analyzingContent: some View {
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
                    .foregroundColor(ThemeColors.textSecondaryDark)
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
    }
    
    // MARK: - Error Content
    
    private func errorContent(message: String) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Error Icon
            ZStack {
                Circle()
                    .fill(ThemeColors.errorRed.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(ThemeColors.errorRed)
            }
            
            // Error Message
            VStack(spacing: 12) {
                Text("Something went wrong")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ThemeColors.textOnDark)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(ThemeColors.textSecondaryDark)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Action Buttons
            VStack(spacing: 16) {
                // Retry Button
                Button(action: retryAnalysis) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry")
                    }
                    .font(.headline)
                    .foregroundColor(ThemeColors.textOnDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(ThemeColors.accentGreen)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
                
                // Upload Different File Button
                Button(action: uploadDifferentFile) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.badge.plus")
                        Text("Upload Different File")
                    }
                    .font(.headline)
                    .foregroundColor(ThemeColors.textOnDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(ThemeColors.brandPurpleMid)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func retryAnalysis() {
        // Reset state and restart polling
        viewState = .analyzing
        currentStep = 0
        pollCount = 0
        startPolling()
    }
    
    private func uploadDifferentFile() {
        // Navigate back to upload screen
        dismiss()
    }
    
    // MARK: - Helpers
    
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
                    print("DEBUG: Polling session status... (attempt \(pollCount + 1)/\(maxPollCount))")
                    
                    let status = try await APIService.shared.getSessionStatus(viewToken: viewToken)
                    
                    print("DEBUG: Received status:", status.status ?? "nil")
                    
                    await MainActor.run {
                        sessionStatus = status.status
                        pollCount += 1
                        
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
                            let errorMsg = status.error_message ?? "An unknown error occurred while analyzing your résumé."
                            print("DEBUG: Status failed:", errorMsg)
                            await MainActor.run {
                                viewState = .error(message: errorMsg)
                            }
                            break
                        }
                    }
                    
                    // Check for timeout
                    if pollCount >= maxPollCount {
                        print("DEBUG: Polling timeout reached (\(maxPollCount) attempts)")
                        await MainActor.run {
                            viewState = .error(message: "Analysis is taking longer than expected. Please try again.")
                        }
                        break
                    }
                    
                } catch let error as APIError {
                    print("DEBUG: API error polling status:", error.localizedDescription ?? "Unknown")
                    await MainActor.run {
                        viewState = .error(message: error.localizedDescription ?? "Failed to check analysis status.")
                    }
                    break
                    
                } catch {
                    print("DEBUG: Error polling status:", error.localizedDescription)
                    await MainActor.run {
                        viewState = .error(message: "Network error: \(error.localizedDescription)")
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
            
            let directCount = fetchedJobs.filter { $0.category?.lowercased() == "direct" }.count
            let adjacentCount = fetchedJobs.filter { $0.category?.lowercased() == "adjacent" }.count
            
            await MainActor.run {
                withAnimation {
                    currentStep = steps.count
                }
                
                jobs = fetchedJobs
                
                let lastSearchInfo = AppState.LastSearchInfo(
                    viewToken: viewToken,
                    date: Date(),
                    totalMatches: fetchedJobs.count,
                    directMatches: directCount,
                    adjacentMatches: adjacentCount,
                    label: fetchedJobs.first?.title
                )
                appState.saveLastSearch(lastSearchInfo)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navigateToResults = true
                }
            }
        } catch {
            print("DEBUG: Error fetching jobs:", error.localizedDescription)
            await MainActor.run {
                viewState = .error(message: "Failed to load job matches. Please try again.")
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

// MARK: - Pipeline Step Row (triadic palette)

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
                    // Green checkmark for completed
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(ThemeColors.textOnDark)
                } else if status == .inProgress {
                    Circle()
                        .stroke(ThemeColors.accentGreen, lineWidth: 2)
                        .frame(width: 44, height: 44)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: ThemeColors.accentSand))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: step.icon)
                        .font(.title3)
                        .foregroundColor(ThemeColors.textOnDark.opacity(0.4))
                }
            }
            
            Text(step.title)
                .font(.headline)
                .foregroundColor(textColor)
            
            Spacer()
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .completed:
            return ThemeColors.accentGreen
        case .inProgress:
            return ThemeColors.brandPurpleMid.opacity(0.3)
        case .pending:
            return ThemeColors.brandPurpleMid.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        switch status {
        case .completed:
            return ThemeColors.textOnDark
        case .inProgress:
            return ThemeColors.accentSand
        case .pending:
            return ThemeColors.textOnDark.opacity(0.5)
        }
    }
}

#Preview {
    NavigationStack {
        SearchAnalyzingView(viewToken: "sample_token")
    }
}

