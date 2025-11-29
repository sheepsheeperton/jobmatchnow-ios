import SwiftUI
import SafariServices

// MARK: - Safari View

/// In-app Safari view for opening URLs
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true
        
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.preferredControlTintColor = UIColor(ThemeColors.primaryComplement)
        return safari
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - URL Opening Helper

extension View {
    /// Opens a URL in an in-app Safari view
    func openURL(_ url: URL?, isPresented: Binding<Bool>) -> some View {
        self.sheet(isPresented: isPresented) {
            if let url = url {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}

