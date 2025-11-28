import SwiftUI

// MARK: - Onboarding Page Model

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}

// MARK: - Onboarding Carousel View

/// Multi-page onboarding carousel explaining app features
struct OnboardingCarouselView: View {
    @StateObject private var appState = AppState.shared
    @State private var currentPage = 0
    let onComplete: () -> Void
    
    // MARK: - Pages
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "doc.text.magnifyingglass",
            title: "Upload Your Résumé",
            subtitle: "Simply upload your résumé in PDF, Word, or image format. Our AI will analyze your skills, experience, and career goals.",
            color: Theme.primaryBlue
        ),
        OnboardingPage(
            icon: "cpu",
            title: "AI-Powered Matching",
            subtitle: "Our intelligent pipeline generates targeted search queries and matches you with real, live job postings that fit your profile.",
            color: Color.purple
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Your Data is Secure",
            subtitle: "We treat your résumé with care. Your data is encrypted and never shared with third parties without your consent.",
            color: Color.green
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.08, green: 0.12, blue: 0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button (not on last page)
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            withAnimation {
                                currentPage = pages.count - 1
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                    } else {
                        // Placeholder for layout
                        Text("")
                            .padding()
                    }
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Theme.primaryBlue : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.vertical, 20)
                
                // Bottom buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        // Get Started button on last page
                        Button(action: {
                            appState.completeOnboarding()
                            onComplete()
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Theme.primaryBlue)
                                .cornerRadius(Theme.CornerRadius.medium)
                        }
                    } else {
                        // Next button
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Theme.primaryBlue)
                                .cornerRadius(Theme.CornerRadius.medium)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Individual Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.icon)
                    .font(.system(size: 60))
                    .foregroundColor(page.color)
            }
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingCarouselView(onComplete: {})
}

