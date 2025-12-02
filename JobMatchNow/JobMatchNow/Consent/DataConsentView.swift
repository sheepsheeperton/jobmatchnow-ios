import SwiftUI

// MARK: - Data Consent View

/// Full-screen consent view shown before first resume upload
/// Explains how data is processed and requires explicit consent
struct DataConsentView: View {
    @StateObject private var appState = AppState.shared
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfUse = false
    
    let onConsent: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        ZStack {
            ThemeColors.surfaceLight
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header with logo
                    headerSection
                    
                    // Main content
                    VStack(spacing: 20) {
                        explanationSection
                        dataUsageBullets
                        whyThisMattersSection
                        consentStatementCard
                    }
                    .padding(.horizontal, 24)
                    
                    // Action buttons
                    buttonSection
                        .padding(.horizontal, 24)
                    
                    // Footer links
                    footerLinks
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                }
            }
        }
        .statusBarDarkContent()
        .sheet(isPresented: $showPrivacyPolicy) {
            SafariView(url: URL(string: "https://www.jobmatchnow.ai/privacy")!)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showTermsOfUse) {
            SafariView(url: URL(string: "https://www.jobmatchnow.ai/terms")!)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App logo
            ZStack {
                Circle()
                    .fill(ThemeColors.accentSand)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 36))
                    .foregroundColor(ThemeColors.primaryBrand)
            }
            .padding(.top, 40)
            
            // Title
            Text("Before we analyze your résumé")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.primaryBrand)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Explanation Section
    
    private var explanationSection: some View {
        Text("To find matching jobs, JobMatchNow securely uploads your résumé, analyzes it using AI, and stores the results so you can revisit your matches later.")
            .font(.body)
            .foregroundColor(ThemeColors.textOnLight)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
    }
    
    // MARK: - Data Usage Bullets
    
    private var dataUsageBullets: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What happens to your data:")
                .font(.headline)
                .foregroundColor(ThemeColors.primaryBrand)
                .padding(.bottom, 4)
            
            BulletPoint(
                icon: "lock.shield.fill",
                text: "Your résumé file is uploaded to our servers and stored in encrypted form."
            )
            
            BulletPoint(
                icon: "cpu",
                text: "AI (Anthropic Claude) extracts your name, contact details, work history, skills, and education."
            )
            
            BulletPoint(
                icon: "magnifyingglass",
                text: "We use this profile to generate job search queries and fetch listings from external job APIs."
            )
            
            BulletPoint(
                icon: "link",
                text: "Your results are linked to a share-safe token so you can revisit them in your dashboard."
            )
            
            BulletPoint(
                icon: "hand.raised.fill",
                text: "We do not sell your data or share it with employers without your consent."
            )
        }
        .padding(16)
        .background(ThemeColors.cardLight)
        .cornerRadius(Theme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(ThemeColors.borderSubtle, lineWidth: 1)
        )
    }
    
    // MARK: - Why This Matters Section
    
    private var whyThisMattersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(ThemeColors.accentGreen)
                Text("Why this matters")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.primaryBrand)
            }
            
            Text("Résumés contain personal information like your name, work history, and contact details. We need your explicit permission before processing this data with AI.")
                .font(.subheadline)
                .foregroundColor(ThemeColors.textSecondaryLight)
                .lineSpacing(3)
        }
    }
    
    // MARK: - Consent Statement Card
    
    private var consentStatementCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundColor(ThemeColors.accentGreen)
            
            Text("By tapping 'I Agree and Continue', you consent to JobMatchNow uploading your résumé file to our servers, processing its contents with AI to extract your profile, and using that information to search for and display job listings. You also confirm that you've reviewed our Privacy Policy and Terms of Use.")
                .font(.caption)
                .foregroundColor(ThemeColors.textOnLight)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(16)
        .background(ThemeColors.accentSand.opacity(0.5))
        .cornerRadius(Theme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(ThemeColors.accentSandDark, lineWidth: 1)
        )
    }
    
    // MARK: - Button Section
    
    private var buttonSection: some View {
        VStack(spacing: 12) {
            // Primary consent button
            Button(action: {
                appState.acceptDataConsent()
                onConsent()
            }) {
                Text("I Agree and Continue")
                    .font(.headline)
                    .foregroundColor(ThemeColors.textOnDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(ThemeColors.accentGreen)
                    .cornerRadius(Theme.CornerRadius.medium)
            }
            
            // Secondary decline button
            Button(action: {
                onDecline()
            }) {
                Text("Not now")
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.textSecondaryLight)
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - Footer Links
    
    private var footerLinks: some View {
        HStack(spacing: 4) {
            Text("Learn more in our")
                .font(.caption)
                .foregroundColor(ThemeColors.textSecondaryLight)
            
            Button("Privacy Policy") {
                showPrivacyPolicy = true
            }
            .font(.caption)
            .foregroundColor(ThemeColors.accentGreen)
            
            Text("and")
                .font(.caption)
                .foregroundColor(ThemeColors.textSecondaryLight)
            
            Button("Terms of Use") {
                showTermsOfUse = true
            }
            .font(.caption)
            .foregroundColor(ThemeColors.accentGreen)
        }
    }
}

// MARK: - Bullet Point Component

private struct BulletPoint: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(ThemeColors.accentGreen)
                .frame(width: 20)
                .padding(.top, 2)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(ThemeColors.textOnLight)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Data Consent Info View (for Settings)

/// Static info view showing data usage explanation (non-gating)
struct DataConsentInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfUse = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(ThemeColors.accentSand)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "cpu")
                            .font(.system(size: 36))
                            .foregroundColor(ThemeColors.primaryBrand)
                    }
                    
                    Text("How We Use Your Data")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ThemeColors.primaryBrand)
                }
                .padding(.top, 24)
                
                // Explanation
                Text("When you upload a résumé, JobMatchNow processes it using AI to help you find relevant job opportunities. Here's how it works:")
                    .font(.body)
                    .foregroundColor(ThemeColors.textOnLight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                
                // Data usage bullets
                VStack(alignment: .leading, spacing: 12) {
                    BulletPoint(
                        icon: "arrow.up.doc.fill",
                        text: "Your résumé is securely uploaded and stored in encrypted form on our servers."
                    )
                    
                    BulletPoint(
                        icon: "cpu",
                        text: "We use Anthropic Claude AI to extract your professional profile, including work history, skills, and education."
                    )
                    
                    BulletPoint(
                        icon: "magnifyingglass",
                        text: "Your profile generates targeted job searches across multiple job boards and APIs."
                    )
                    
                    BulletPoint(
                        icon: "rectangle.stack",
                        text: "Results are saved to your dashboard so you can revisit them anytime."
                    )
                    
                    BulletPoint(
                        icon: "lock.shield.fill",
                        text: "Your data is never sold. We don't share it with employers without your explicit action."
                    )
                }
                .padding(16)
                .background(ThemeColors.cardLight)
                .cornerRadius(Theme.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .stroke(ThemeColors.borderSubtle, lineWidth: 1)
                )
                .padding(.horizontal, 24)
                
                // Links
                VStack(spacing: 16) {
                    Button(action: { showPrivacyPolicy = true }) {
                        HStack {
                            Label("Privacy Policy", systemImage: "hand.raised")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                        .foregroundColor(ThemeColors.textOnLight)
                        .padding()
                        .background(ThemeColors.cardLight)
                        .cornerRadius(Theme.CornerRadius.small)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                .stroke(ThemeColors.borderSubtle, lineWidth: 1)
                        )
                    }
                    
                    Button(action: { showTermsOfUse = true }) {
                        HStack {
                            Label("Terms of Use", systemImage: "doc.text")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                        .foregroundColor(ThemeColors.textOnLight)
                        .padding()
                        .background(ThemeColors.cardLight)
                        .cornerRadius(Theme.CornerRadius.small)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                .stroke(ThemeColors.borderSubtle, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(ThemeColors.surfaceLight)
        .navigationTitle("Data & AI Processing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(ThemeColors.accentGreen)
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            SafariView(url: URL(string: "https://www.jobmatchnow.ai/privacy")!)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showTermsOfUse) {
            SafariView(url: URL(string: "https://www.jobmatchnow.ai/terms")!)
                .ignoresSafeArea()
        }
    }
}

#Preview("Consent View") {
    DataConsentView(
        onConsent: { print("Consented") },
        onDecline: { print("Declined") }
    )
}

#Preview("Info View") {
    NavigationStack {
        DataConsentInfoView()
    }
}

