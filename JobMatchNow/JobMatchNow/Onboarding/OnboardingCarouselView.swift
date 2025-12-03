//
//  OnboardingCarouselView.swift
//  JobMatchNow
//
//  Three-screen onboarding carousel for first-time users.
//  Dark, minimal, card-based style using canonical ThemeColors.
//

import SwiftUI

// MARK: - Onboarding Page Model

struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let fallbackIcon: String
    let headline: String
    let subcopy: String
    let ctaText: String
}

// MARK: - Onboarding Carousel View

/// Multi-page onboarding carousel with card-based design
struct OnboardingCarouselView: View {
    @StateObject private var appState = AppState.shared
    @State private var currentPage = 0
    let onComplete: () -> Void
    
    // MARK: - Pages Data
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "onboarding_personalized",
            fallbackIcon: "person.crop.rectangle.stack.fill",
            headline: "Personalized job matches, powered by your unique experience",
            subcopy: "We analyze your skills, experience, and education with advanced AI to surface roles that fit you, not the other way around. Choose your preferred work style — remote, hybrid, or on-site — and get instantly matched.",
            ctaText: "Next"
        ),
        OnboardingPage(
            imageName: "onboarding_ai_matcher",
            fallbackIcon: "cpu.fill",
            headline: "Not a job board — a smart matcher built around your résumé",
            subcopy: "Unlike generic job search engines, JobMatchNow scans your résumé using AI-driven character recognition to understand what you bring to the table — then matches you with jobs that align with your actual strengths.",
            ctaText: "Next"
        ),
        OnboardingPage(
            imageName: "onboarding_fast_results",
            fallbackIcon: "bolt.fill",
            headline: "Get job recommendations in under 60 seconds",
            subcopy: "Upload your résumé once and instantly unlock curated opportunities tailored to your profile. No endless searching — just real, relevant roles delivered directly to you.",
            ctaText: "Get started"
        )
    ]
    
    var body: some View {
        ZStack {
            // Dark gradient background
            ThemeColors.introGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content with TabView
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(
                            page: page,
                            isLastPage: index == pages.count - 1,
                            onNext: {
                                if index == pages.count - 1 {
                                    appState.completeOnboarding()
                                    onComplete()
                                } else {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPage += 1
                                    }
                                }
                            }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom page indicator
                OnboardingPageIndicator(
                    totalPages: pages.count,
                    currentPage: currentPage
                )
                .padding(.bottom, 40)
            }
        }
        .statusBarLightContent()
    }
}

// MARK: - Individual Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Card container
            VStack(spacing: 28) {
                // Illustration
                OnboardingIllustration(
                    imageName: page.imageName,
                    fallbackIcon: page.fallbackIcon
                )
                .frame(height: 220) // Increased height for scenes
                
                // Text content
                VStack(spacing: 16) {
                    Text(page.headline)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeColors.textOnDark)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                    
                    Text(page.subcopy)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(ThemeColors.textSecondaryDark)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 8)
                
                // CTA Button
                Button(action: onNext) {
                    Text(page.ctaText)
                        .font(.headline)
                        .foregroundColor(ThemeColors.textOnDark)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(ThemeColors.accentGreen)
                        .cornerRadius(Theme.CornerRadius.medium)
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(ThemeColors.cardDark)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Onboarding Illustration

/// Displays image if available, otherwise shows a specialized scene or graceful fallback
struct OnboardingIllustration: View {
    let imageName: String
    let fallbackIcon: String
    
    var body: some View {
        // Check if asset exists
        if let uiImage = UIImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
        } else {
            // Specialized Scenes
            if imageName == "onboarding_personalized" {
                OnboardingScenePersonalized()
            } else if imageName == "onboarding_ai_matcher" {
                OnboardingSceneAIMatcher()
            }
            // Add future scenes here for fast_results
            else {
                // Generic Fallback: gradient circle with SF Symbol
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    ThemeColors.accentGreen.opacity(0.3),
                                    ThemeColors.brandPurpleMid.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 180, height: 180)
                    
                    // Inner gradient circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    ThemeColors.brandPurpleMid.opacity(0.5),
                                    ThemeColors.brandPurpleDark.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    // Icon
                    Image(systemName: fallbackIcon)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(ThemeColors.accentSand)
                }
            }
        }
    }
}

// MARK: - Page Indicator

struct OnboardingPageIndicator: View {
    let totalPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? ThemeColors.accentGreen : ThemeColors.brandPurpleMid.opacity(0.5))
                    .frame(
                        width: index == currentPage ? 24 : 8,
                        height: 8
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingCarouselView(onComplete: {})
}
