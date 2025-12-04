//
//  InsightsView.swift
//  JobMatchNow
//
//  Displays AI-powered insights: Resume Score and Suggested Roles.
//  Uses the same design patterns as Dashboard and Search modules.
//

import SwiftUI

// MARK: - Insights View

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .empty:
                emptyStateView
            case .error(let message):
                errorView(message: message)
            case .loaded:
                insightsContent
            }
        }
        .background(ThemeColors.surfaceLight)
        .statusBarDarkContent()
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.light, for: .navigationBar)
        .onAppear {
            Task {
                await viewModel.loadLatestSessionInsights()
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(ThemeColors.accentGreen)
            Text("Loading insights...")
                .font(.subheadline)
                .foregroundColor(ThemeColors.textSecondaryLight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(ThemeColors.errorRed.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundColor(ThemeColors.errorRed)
            }
            
            VStack(spacing: 8) {
                Text("Something Went Wrong")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.primaryBrand)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(ThemeColors.textSecondaryLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { viewModel.retry() }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.headline)
                .foregroundColor(ThemeColors.textOnDark)
                .frame(width: 160, height: 50)
                .background(ThemeColors.accentGreen)
                .cornerRadius(Theme.CornerRadius.medium)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(ThemeColors.accentSand)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundColor(ThemeColors.primaryBrand)
            }
            
            VStack(spacing: 8) {
                Text("No Insights Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.primaryBrand)
                
                Text("Upload your résumé to get personalized insights about your career profile and suggested roles.")
                    .font(.body)
                    .foregroundColor(ThemeColors.textSecondaryLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                AppState.shared.switchToTab(.search)
                dismiss()
            }) {
                Text("Upload Résumé")
                    .font(.headline)
                    .foregroundColor(ThemeColors.textOnDark)
                    .frame(width: 200, height: 50)
                    .background(ThemeColors.accentGreen)
                    .cornerRadius(Theme.CornerRadius.medium)
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Insights Content
    
    private var insightsContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Resume Score Section
                if let score = viewModel.resumeScore {
                    resumeScoreCard(score: score, feedback: viewModel.resumeFeedback)
                }
                
                // Suggested Roles Section
                if !viewModel.suggestedRoles.isEmpty {
                    suggestedRolesSection
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Resume Score Card (Fully Expanded)
    
    private func resumeScoreCard(score: Int, feedback: String?) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.title3)
                    .foregroundColor(ThemeColors.primaryBrand)
                
                Text("Resume Score")
                    .font(.headline)
                    .foregroundColor(ThemeColors.primaryBrand)
                
                Spacer()
                
                // Score badge
                Text("\(score) / 100")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(scoreColor(for: score))
            }
            
            // Score bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 6)
                        .fill(ThemeColors.borderSubtle)
                        .frame(height: 12)
                    
                    // Filled portion
                    RoundedRectangle(cornerRadius: 6)
                        .fill(scoreColor(for: score))
                        .frame(width: geometry.size.width * CGFloat(score) / 100, height: 12)
                }
            }
            .frame(height: 12)
            
            // Feedback text (fully expanded)
            if let feedback = feedback, !feedback.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                Text("AI Feedback")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.primaryBrand)
                
                Text(feedback)
                    .font(.body)
                    .foregroundColor(ThemeColors.textOnLight)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(ThemeColors.cardLight)
        .cornerRadius(Theme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(ThemeColors.borderSubtle, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private func scoreColor(for score: Int) -> Color {
        if score >= 80 { return ThemeColors.accentGreen }
        if score >= 60 { return ThemeColors.warningAmber }
        return ThemeColors.errorRed
    }
    
    // MARK: - Suggested Roles Section
    
    private var suggestedRolesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundColor(ThemeColors.accentGreen)
                
                Text("Suggested Roles for You")
                    .font(.headline)
                    .foregroundColor(ThemeColors.primaryBrand)
                
                Spacer()
            }
            
            Text("Tap a role to see why you might be a great fit")
                .font(.caption)
                .foregroundColor(ThemeColors.textSecondaryLight)
            
            // Role chips with expandable explanations
            VStack(spacing: 12) {
                ForEach(viewModel.suggestedRoles, id: \.self) { role in
                    RoleChipView(
                        role: role,
                        isExpanded: viewModel.expandedRole == role,
                        snippetResponse: viewModel.roleExplanations[role],
                        isLoading: viewModel.isLoadingExplanation && viewModel.expandedRole == role,
                        error: viewModel.expandedRole == role ? viewModel.explanationError : nil,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                viewModel.toggleRoleExplanation(role)
                            }
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(ThemeColors.cardLight)
        .cornerRadius(Theme.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(ThemeColors.borderSubtle, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Role Chip View

struct RoleChipView: View {
    let role: String
    let isExpanded: Bool
    let snippetResponse: RoleSnippetResponse?
    let isLoading: Bool
    let error: String?
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Chip button
            Button(action: onTap) {
                HStack {
                    Text(role)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isExpanded ? ThemeColors.textOnDark : ThemeColors.primaryBrand)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(isExpanded ? ThemeColors.textOnDark.opacity(0.7) : ThemeColors.textSecondaryLight)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(isExpanded ? ThemeColors.accentGreen : ThemeColors.accentSand)
                .cornerRadius(Theme.CornerRadius.small)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded explanation
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    if isLoading {
                        // Loading state
                        HStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(ThemeColors.accentGreen)
                            
                            Text("Analyzing your fit for this role…")
                                .font(.subheadline)
                                .foregroundColor(ThemeColors.textSecondaryLight)
                                .italic()
                            
                            Spacer()
                        }
                    } else if let error = error {
                        // Error state
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.caption)
                                .foregroundColor(ThemeColors.warningAmber)
                            
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(ThemeColors.textSecondaryLight)
                        }
                    } else if let response = snippetResponse {
                        // Summary paragraph
                        Text(response.summary)
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.textOnLight)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Bullets list
                        if !response.bullets.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(response.bullets, id: \.self) { bullet in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(ThemeColors.accentGreen)
                                            .padding(.top, 2)
                                        
                                        Text(bullet)
                                            .font(.subheadline)
                                            .foregroundColor(ThemeColors.textOnLight.opacity(0.85))
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                .padding(16)
                .background(ThemeColors.accentSand.opacity(0.3))
                .cornerRadius(Theme.CornerRadius.small)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Preview

#Preview("Insights - Loaded") {
    NavigationStack {
        InsightsView()
    }
}

