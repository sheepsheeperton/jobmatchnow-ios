//
//  StatusBarStyleManager.swift
//  JobMatchNow
//
//  Manages status bar style (light/dark) across SwiftUI views.
//  Views can request their preferred style using .preferredStatusBarStyle() modifier.
//

import SwiftUI
import Combine

// MARK: - Status Bar Style Manager

/// Observable manager that controls status bar appearance
final class StatusBarStyleManager: ObservableObject {
    static let shared = StatusBarStyleManager()
    
    @Published var statusBarStyle: UIStatusBarStyle = .default
    
    private init() {}
    
    func setStyle(_ style: UIStatusBarStyle) {
        DispatchQueue.main.async {
            self.statusBarStyle = style
        }
    }
}

// MARK: - Status Bar Hosting Controller

/// Custom hosting controller that respects StatusBarStyleManager
class StatusBarHostingController<Content: View>: UIHostingController<Content> {
    private var cancellable: AnyCancellable?
    
    override init(rootView: Content) {
        super.init(rootView: rootView)
        
        // Subscribe to status bar style changes
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
}

// MARK: - Status Bar Style Preference Key

struct StatusBarStylePreferenceKey: PreferenceKey {
    static var defaultValue: UIStatusBarStyle = .default
    
    static func reduce(value: inout UIStatusBarStyle, nextValue: () -> UIStatusBarStyle) {
        value = nextValue()
    }
}

// MARK: - View Extension for Status Bar Style

extension View {
    /// Sets the preferred status bar style for this view hierarchy
    /// - Parameter style: .lightContent for dark backgrounds, .darkContent for light backgrounds
    func preferredStatusBarStyle(_ style: UIStatusBarStyle) -> some View {
        self
            .preference(key: StatusBarStylePreferenceKey.self, value: style)
            .onAppear {
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

