import SwiftUI

struct WelcomeView: View {
    @State private var navigateToUpload = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                // App Title and Subtitle
                VStack(spacing: 12) {
                    Text("JobMatchNow")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Upload your résumé, see real job matches.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Feature bullet points
                VStack(alignment: .leading, spacing: 20) {
                    FeatureBulletPoint(
                        icon: "doc.text.magnifyingglass",
                        text: "Parses your résumé using AI"
                    )

                    FeatureBulletPoint(
                        icon: "magnifyingglass.circle.fill",
                        text: "Generates targeted job search queries"
                    )

                    FeatureBulletPoint(
                        icon: "checkmark.seal.fill",
                        text: "Matches you with real live job posts"
                    )
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)

                Spacer()

                // Navigation buttons
                VStack(spacing: 16) {
                    // Primary CTA button
                    NavigationLink(destination: UploadResumeView()) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Secondary login button
                    NavigationLink(destination: UploadResumeView()) {
                        Text("Already have an account? Log in")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal)
            .background(Color(UIColor.systemBackground))
        }
    }
}

// Reusable component for feature bullet points
struct FeatureBulletPoint: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)

            Text(text)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

#Preview {
    WelcomeView()
}