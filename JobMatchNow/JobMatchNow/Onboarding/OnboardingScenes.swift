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

// MARK: - Scene 2: AI Résumé Scanning

/// "A magnifying glass, document, and AI scanning beam represented using geometric shapes. Visual metaphor: smart analysis of a résumé."
struct OnboardingSceneAIMatcher: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Background Glow
            Circle()
                .fill(ThemeColors.brandPurpleDark.opacity(0.2))
                .blur(radius: 40)
                .frame(width: 220, height: 220)
            
            // The Document
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeColors.surfaceWhite)
                    .frame(width: 160, height: 210)
                    .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
                
                // Document Content (Abstract Lines)
                VStack(alignment: .leading, spacing: 10) {
                    // Header block
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ThemeColors.brandPurpleMid.opacity(0.2))
                        .frame(width: 80, height: 14)
                        .padding(.bottom, 8)
                    
                    // Body lines
                    ForEach(0..<6) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(ThemeColors.softGrey.opacity(0.15))
                            .frame(width: i % 2 == 0 ? 120 : 90, height: 8)
                    }
                    Spacer()
                }
                .padding(24)
                .frame(width: 160, height: 210)
                
                // Scan Beam / Data Extraction Highlights
                // (Only appears when scan line passes over)
                VStack(spacing: 18) {
                    ForEach(0..<3) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(ThemeColors.accentGreen.opacity(0.4))
                            .frame(width: 120, height: 8)
                            .opacity(animate ? 1 : 0)
                            .animation(
                                Animation.easeInOut(duration: 0.5)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.2),
                                value: animate
                            )
                    }
                }
                .offset(y: 10)
            }
            .scaleEffect(0.9)
            
            // The Lens / Scanner
            // Moving up and down
            ZStack {
                // Lens Ring
                Circle()
                    .strokeBorder(ThemeColors.brandPurpleMid, lineWidth: 8)
                    .background(Circle().fill(ThemeColors.brandPurpleDark.opacity(0.1)))
                    .frame(width: 100, height: 100)
                
                // Glass reflection
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.4), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                
                // Handle
                Capsule()
                    .fill(ThemeColors.brandPurpleDark)
                    .frame(width: 12, height: 60)
                    .offset(y: 60)
                    .rotationEffect(.degrees(-45), anchor: .top)
                    .offset(x: 30, y: 30)
            }
            .offset(y: animate ? 40 : -60) // Scan movement
            .offset(x: animate ? 20 : -20) // Slight horizontal movement
            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animate)
            
            // Floating Data Particles (Extracted info)
            Group {
                Circle()
                    .fill(ThemeColors.accentGreen)
                    .frame(width: 12, height: 12)
                    .offset(x: 60, y: -40)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1.2 : 0)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(ThemeColors.accentSand)
                    .frame(width: 20, height: 8)
                    .offset(x: -70, y: 20)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1.2 : 0)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: true).delay(1.0), value: animate)
        }
        .frame(height: 240)
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Scene 3: Fast Results

/// "A stylized stopwatch or fast-forward icon combined with upward-moving shapes. Convey speed, quick results, and instant matching."
struct OnboardingSceneFastResults: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Background: Upward "Speed Lines"
            ForEach(0..<3) { i in
                Image(systemName: "chevron.up")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(ThemeColors.accentGreen.opacity(0.1))
                    .offset(y: animate ? -80 : 80)
                    .scaleEffect(animate ? 1.2 : 0.8)
                    .opacity(animate ? 0 : 1)
                    .animation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.5),
                        value: animate
                    )
            }
            
            // Central Stopwatch / Timer Element
            ZStack {
                // Outer Ring
                Circle()
                    .stroke(ThemeColors.brandPurpleDark, lineWidth: 8)
                    .frame(width: 140, height: 140)
                    .opacity(0.3)
                
                // Progress Ring (Animated)
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [ThemeColors.accentGreen, ThemeColors.brandPurpleMid]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(animate ? 360 : 0))
                    .animation(Animation.linear(duration: 4).repeatForever(autoreverses: false), value: animate)
                
                // Inner Face
                Circle()
                    .fill(ThemeColors.surfaceWhite)
                    .frame(width: 110, height: 110)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
                
                // Clock Hand
                Capsule()
                    .fill(ThemeColors.brandPurpleDark)
                    .frame(width: 6, height: 50)
                    .offset(y: -20)
                    .rotationEffect(.degrees(animate ? 360 : 0))
                    .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: animate)
                
                // Center Pin
                Circle()
                    .fill(ThemeColors.accentGreen)
                    .frame(width: 12, height: 12)
            }
            
            // Floating Result Cards (Popping up)
            Group {
                // Left card
                RoundedRectangle(cornerRadius: 6)
                    .fill(ThemeColors.brandPurpleMid)
                    .frame(width: 50, height: 35)
                    .rotationEffect(.degrees(-15))
                    .offset(x: -70, y: 20)
                    .offset(y: animate ? -10 : 10)
                    .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animate)
                
                // Right card
                RoundedRectangle(cornerRadius: 6)
                    .fill(ThemeColors.accentSand)
                    .frame(width: 40, height: 30)
                    .rotationEffect(.degrees(10))
                    .offset(x: 70, y: -30)
                    .offset(y: animate ? 15 : -15)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
                
                // Top icon (Thunderbolt/Speed)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 24))
                    .foregroundColor(ThemeColors.accentGreen)
                    .offset(x: 40, y: -60)
                    .scaleEffect(animate ? 1.2 : 0.8)
                    .opacity(animate ? 1 : 0.5)
                    .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animate)
            }
        }
        .frame(height: 240)
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        ThemeColors.introGradient.ignoresSafeArea()
        VStack(spacing: 40) {
            OnboardingScenePersonalized()
            OnboardingSceneAIMatcher()
            OnboardingSceneFastResults()
        }
    }
}
