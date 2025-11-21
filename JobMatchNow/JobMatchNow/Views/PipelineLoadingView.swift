import SwiftUI

struct PipelineLoadingView: View {
    let viewToken: String

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
                    .multilineTextAlignment(.center)

                Text("This will only take a moment")
                    .font(.body)
                    .foregroundColor(.secondary)
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
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToResults) {
            ResultsView(jobs: jobs)
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
                    // Poll session status
                    print("DEBUG: Polling session status...")
                    let status = try await APIService.shared.getSessionStatus(viewToken: viewToken)

                    print("DEBUG: Received status:", status.status ?? "nil")

                    await MainActor.run {
                        sessionStatus = status.status

                        // Animate step progression for visual feedback
                        if currentStep < steps.count - 1 {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }

                    // Check status
                    if let statusValue = status.status {
                        if statusValue == "completed" {
                            print("DEBUG: Status completed, fetching jobs")
                            // Fetch jobs and navigate
                            await fetchJobsAndNavigate()
                            break
                        } else if statusValue == "failed" {
                            print("DEBUG: Status failed:", status.error_message ?? "No error message")
                            // Show error
                            await MainActor.run {
                                errorMessage = status.error_message ?? "An unknown error occurred"
                                showErrorAlert = true
                            }
                            break
                        } else if statusValue == "running" {
                            print("DEBUG: Status running, continuing to poll")
                        } else {
                            print("DEBUG: Unexpected status value:", statusValue)
                        }
                    } else {
                        print("DEBUG: Status is nil!")
                    }

                } catch {
                    // Handle network/API errors
                    print("DEBUG: Error polling status:", error.localizedDescription)
                    await MainActor.run {
                        errorMessage = "Failed to check status: \(error.localizedDescription)"
                        showErrorAlert = true
                    }
                    break
                }

                // Wait 2 seconds before next poll
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

            await MainActor.run {
                // Mark all steps as complete
                withAnimation {
                    currentStep = steps.count
                }

                // Store jobs and navigate
                jobs = fetchedJobs

                print("DEBUG: Jobs stored, scheduling navigation")

                // Wait a moment to show completion
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("DEBUG: Setting navigateToResults = true")
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

// Model for pipeline step
struct PipelineStep {
    let icon: String
    let title: String
}

enum StepStatus {
    case pending
    case inProgress
    case completed
}

// Individual step row component
struct PipelineStepRow: View {
    let step: PipelineStep
    let status: StepStatus

    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 44, height: 44)

                if status == .completed {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                } else if status == .inProgress {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: step.icon)
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }

            // Step title
            Text(step.title)
                .font(.headline)
                .foregroundColor(status == .pending ? .secondary : .primary)

            Spacer()
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .completed:
            return .green
        case .inProgress:
            return .blue
        case .pending:
            return Color(UIColor.systemGray5)
        }
    }
}

#Preview {
    NavigationStack {
        PipelineLoadingView(viewToken: "sample_token")
    }
}
