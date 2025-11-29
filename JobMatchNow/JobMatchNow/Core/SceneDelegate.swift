//
//  SceneDelegate.swift
//  JobMatchNow
//
//  Custom SceneDelegate that uses RootHostingController for status bar control.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Create the root SwiftUI view with environment objects
        let rootView = RootView()
            .environmentObject(AppState.shared)
            .environmentObject(StatusBarStyleManager.shared)
        
        // Use our custom RootHostingController instead of default UIHostingController
        let hostingController = RootHostingController(rootView: rootView)
        
        // Create window and set root view controller
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        self.window = window
        
        // Handle any URLs passed at launch
        if let urlContext = connectionOptions.urlContexts.first {
            handleURL(urlContext.url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Handle OAuth callback URLs
        if let urlContext = URLContexts.first {
            handleURL(urlContext.url)
        }
    }
    
    private func handleURL(_ url: URL) {
        print("[SceneDelegate] Received URL: \(url)")
        
        // Handle OAuth callbacks (LinkedIn, etc.)
        if url.scheme == "jobmatchnow" && url.host == "auth" {
            print("[SceneDelegate] OAuth callback received")
        }
    }
}

