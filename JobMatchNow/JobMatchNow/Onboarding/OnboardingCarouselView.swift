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
            color: ThemeColors.primaryBrand
        ),
        OnboardingPage(
            icon: "cpu",
            title: "AI-Powered Matching",
            subtitle: "Our intelligent pipeline generates targeted search queries and matches you with real, live job postings that fit your profile.",
            color: ThemeColors.primaryComplement
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Your Data is Secure",
            subtitle: "We treat your résumé with care. Your data is encrypted and never shared with third parties without your consent.",
            color: ThemeColors.deepComplement
        )
    ]
    
    var body: some View {
        ZStack {
            // Background - midnight gradient
            LinearGradient(
                colors: [
                    ThemeColors.midnight,
                    ThemeColors.deepComplement
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
                        .foregroundColor(ThemeColors.textOnDark.opacity(0.7))
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
                            .fill(index == currentPage ? ThemeColors.primaryBrand : ThemeColors.textOnDark.opacity(0.3))
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.vertical, 20)
                
                // Bottom buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        // Get Started button on last page - primary CTA
                        Button(action: {
                            appState.completeOnboarding()
                            onComplete()
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(ThemeColors.textOnDark)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(ThemeColors.primaryBrand)
                                .cornerRadius(Theme.CornerRadius.medium)
                        }
                    } else {
                        // Next button - secondary action
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(ThemeColors.textOnDark)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(ThemeColors.primaryComplement)
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
                    .foregroundColor(ThemeColors.textOnDark)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(ThemeColors.textOnDark.opacity(0.8))
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
