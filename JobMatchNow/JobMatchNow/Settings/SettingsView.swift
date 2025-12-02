import SwiftUI

// MARK: - Settings View

/// App settings (Palette A colors only)
struct SettingsView: View {
    @StateObject private var appState = AppState.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutConfirmation = false
    @State private var showSafari = false
    @State private var safariURL: URL?
    
    var body: some View {
        List {
            // Account Section
            Section {
                HStack {
                    Label("Email", systemImage: "envelope")
                    Spacer()
                    Text(appState.currentUser?.email ?? "Not signed in")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("Connected via", systemImage: "link")
                    Spacer()
                    Text(connectedProviders)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Account")
            }
            
            // Plan Section
            Section {
                HStack {
                    Label("Plan", systemImage: "star")
                    Spacer()
                    Text("Free Beta User")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("Searches", systemImage: "magnifyingglass")
                    Spacer()
                    Text("Unlimited during beta")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            } header: {
                Text("Subscription")
            }
            
            // Links Section
            Section {
                Button(action: {
                    openURL("https://www.jobmatchnow.ai/privacy")
                }) {
                    HStack {
                        Label("Privacy Policy", systemImage: "hand.raised")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
                
                Button(action: {
                    openURL("https://www.jobmatchnow.ai/terms")
                }) {
                    HStack {
                        Label("Terms of Service", systemImage: "doc.text")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
                
                Button(action: {
                    openMailTo()
                }) {
                    HStack {
                        Label("Contact Support", systemImage: "envelope.badge")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
            } header: {
                Text("Legal & Support")
            }
            
            // App Info Section
            Section {
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("Build", systemImage: "hammer")
                    Spacer()
                    Text(buildNumber)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("About")
            }
            
            // Logout Section
            Section {
                Button(role: .destructive, action: {
                    showLogoutConfirmation = true
                }) {
                    HStack {
                        Spacer()
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        Spacer()
                    }
                }
            }
            
            // Debug Section (only in DEBUG builds)
            #if DEBUG
            Section {
                Button(action: {
                    appState.resetOnboarding()
                }) {
                    Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                }
                .foregroundColor(ThemeColors.primaryAccent)
                
                Button(action: {
                    appState.clearLastSearch()
                }) {
                    Label("Clear Last Search", systemImage: "trash")
                }
                .foregroundColor(ThemeColors.primaryAccent)
            } header: {
                Text("Debug")
            }
            #endif
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(ThemeColors.primaryAccent)
            }
        }
        .confirmationDialog(
            "Log Out",
            isPresented: $showLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Log Out", role: .destructive) {
                logOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log out?")
        }
        .sheet(isPresented: $showSafari) {
            if let url = safariURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var connectedProviders: String {
        guard let providers = appState.currentUser?.providers, !providers.isEmpty else {
            return "Email"
        }
        return providers.map { $0.capitalized }.joined(separator: ", ")
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - Actions
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        safariURL = url
        showSafari = true
    }
    
    private func openMailTo() {
        let email = "support@jobmatchnow.ai"
        let subject = "JobMatchNow iOS Support"
        let body = "\n\n---\nApp Version: \(appVersion) (\(buildNumber))\nDevice: \(UIDevice.current.model)\niOS: \(UIDevice.current.systemVersion)"
        
        let mailtoString = "mailto:\(email)?subject=\(subject)&body=\(body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: mailtoString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func logOut() {
        Task {
            await AuthManager.shared.signOut()
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
