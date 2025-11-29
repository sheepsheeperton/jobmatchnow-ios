//
//  StatusBarStyleManager.swift
//  JobMatchNow
//
//  Manages status bar style (light/dark) across SwiftUI views.
//  Uses a custom UIHostingController that reads from this manager.
//

import SwiftUI
import Combine

// MARK: - Status Bar Style Manager

/// Observable manager that controls status bar appearance
/// This is the single source of truth for status bar style.
final class StatusBarStyleManager: ObservableObject {
    static let shared = StatusBarStyleManager()
    
    @Published var statusBarStyle: UIStatusBarStyle = .darkContent
    
    private init() {}
    
    func setStyle(_ style: UIStatusBarStyle) {
        guard statusBarStyle != style else { return }
        DispatchQueue.main.async {
            self.statusBarStyle = style
        }
    }
}

// MARK: - Root Hosting Controller

/// Custom UIHostingController that respects StatusBarStyleManager.
/// This controller must be used as the root view controller for status bar control to work.
final class RootHostingController<Content: View>: UIHostingController<Content> {
    private var cancellable: AnyCancellable?
    
    override init(rootView: Content) {
        super.init(rootView: rootView)
        
        // Subscribe to status bar style changes and trigger updates
        cancellable = StatusBarStyleManager.shared.$statusBarStyle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.setNeedsStatusBarAppearanceUpdate()
            }
    }
    
    @available(*, unavailable)
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return StatusBarStyleManager.shared.statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

// MARK: - View Extension for Status Bar Style

extension View {
    /// Sets the preferred status bar style for this view hierarchy
    /// - Parameter style: .lightContent for dark backgrounds, .darkContent for light backgrounds
    func preferredStatusBarStyle(_ style: UIStatusBarStyle) -> some View {
        self.onAppear {
            StatusBarStyleManager.shared.setStyle(style)
        }
    }
    
    /// Convenience: Use dark status bar icons (for light backgrounds)
    func statusBarDarkContent() -> some View {
        self.preferredStatusBarStyle(.darkContent)
    }
    
    /// Convenience: Use light status bar icons (for dark backgrounds)
    func statusBarLightContent() -> some View {
        self.preferredStatusBarStyle(.lightContent)
    }
}
