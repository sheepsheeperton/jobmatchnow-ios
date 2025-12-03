//
//  OnboardingScenes.swift
//  JobMatchNow
//
//  Programmatic vector illustrations for onboarding.
//  Used as high-fidelity fallbacks (or primary assets) until generic images are replaced.
//

import SwiftUI

// MARK: - Scene 1: Personalized Matching

/// "A stylized representation of a résumé or profile card at center, surrounded by abstract human icons and floating skill badges."
struct OnboardingScenePersonalized: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Background glow (subtle ambient light)
            Circle()
                .fill(ThemeColors.brandPurpleMid.opacity(0.15))
                .blur(radius: 30)
                .frame(width: 200, height: 200)
            
            // Floating Background Elements (Abstract shapes)
            Group {
                // Top right circle (User)
                Circle()
                    .fill(ThemeColors.brandPurpleMid.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .offset(x: 70, y: -50)
                    .scaleEffect(animate ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animate)
                
                // Bottom left circle (User)
                Circle()
                    .fill(ThemeColors.accentSand.opacity(0.3))
                    .frame(width: 30, height: 30)
                    .offset(x: -80, y: 40)
                    .scaleEffect(animate ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animate)
                
                // Top left badge (Skill)
                Capsule()
                    .fill(ThemeColors.accentGreen.opacity(0.2))
                    .frame(width: 50, height: 20)
                    .rotationEffect(.degrees(-15))
                    .offset(x: -60, y: -60)
                    .offset(y: animate ? -5 : 5)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animate)
            }
            
            // Central Resume / Profile Card
            ZStack {
                // Card Body
                RoundedRectangle(cornerRadius: 16)
                    .fill(ThemeColors.surfaceWhite)
                    .frame(width: 140, height: 180)
                    .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
                    // Slight 3D tilt
                    .rotation3DEffect(
                        .degrees(animate ? 2 : -2),
                        axis: (x: 0, y: 1, z: 0)
                    )
                
                // Card Content (Stylized)
                VStack(alignment: .leading, spacing: 12) {
                    // Header / Profile Photo placeholder
                    HStack(spacing: 12) {
                        Circle()
                            .fill(ThemeColors.brandPurpleDark)
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ThemeColors.brandPurpleMid)
                                .frame(width: 60, height: 8)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ThemeColors.softGrey.opacity(0.5))
                                .frame(width: 40, height: 6)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // "Experience" Lines
                    ForEach(0..<3) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(ThemeColors.softGrey.opacity(0.3))
                            .frame(width: 100, height: 6)
                    }
                    
                    // "Skills" Badges (Mini)
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(ThemeColors.accentGreen)
                            .frame(width: 30, height: 12)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(ThemeColors.accentSand) // Darker sand for visibility
                            .frame(width: 30, height: 12)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(ThemeColors.brandPurpleMid)
                            .frame(width: 20, height: 12)
                    }
                    .padding(.top, 4)
                    
                    Spacer()
                }
                .padding(20)
                .frame(width: 140, height: 180)
            }
            .scaleEffect(animate ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
            
            // "Match" Indicator (Badge overlay)
            ZStack {
                Circle()
                    .fill(ThemeColors.surfaceWhite)
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(ThemeColors.accentGreen)
            }
            .offset(x: 50, y: 70) // Bottom right corner of card
            .scaleEffect(animate ? 1.1 : 0.9)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true).delay(1), value: animate)
            
        }
        .frame(height: 220) // Container height
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        ThemeColors.introGradient.ignoresSafeArea()
        OnboardingScenePersonalized()
    }
}

