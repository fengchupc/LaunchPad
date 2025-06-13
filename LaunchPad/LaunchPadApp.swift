//
//  LaunchPadApp.swift
//  LaunchPad
//
//  Created by Chu Feng on 13/6/2025.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct LaunchPadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Set window style, remove close, minimize, and full-screen buttons, and set borderless window
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.styleMask = [.borderless, .fullSizeContentView]
                window.level = .modalPanel
                window.collectionBehavior = [.stationary, .canJoinAllSpaces, .fullScreenAuxiliary]
                window.isMovable = false
                window.setFrame(NSScreen.main?.visibleFrame ?? .zero, display: true)
                
                // Set translucent black background
                window.backgroundColor = .clear // Change to clear background
                window.isOpaque = false
                window.hasShadow = false
                window.ignoresMouseEvents = false // Ensure mouse events can be received
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Ensure window covers screen but does not obscure Dock
                    DispatchQueue.main.async {
                        if let window = NSApplication.shared.windows.first {
                            window.styleMask = [.borderless, .fullSizeContentView]
                            window.setFrame(NSScreen.main?.visibleFrame ?? .zero, display: true) // Use visibleFrame
                        }
                    }
                }
        }
    }
}
