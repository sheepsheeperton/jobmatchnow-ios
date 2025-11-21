import SwiftUI

struct PipelineLoadingView: View {
    @State private var currentStep = 0
    @State private var navigateToResults = false

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
            ResultsView()
        }
        .onAppear {
            startPipeline()
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

    private func startPipeline() {
        // Simulate each step with delays
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            if currentStep < steps.count {
                withAnimation {
                    currentStep += 1
                }
            } else {
                timer.invalidate()
                // Wait a moment before navigating
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    navigateToResults = true
                }
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
        PipelineLoadingView()
    }
}
