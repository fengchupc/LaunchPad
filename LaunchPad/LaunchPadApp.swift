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
        // 设置窗口样式，移除关闭、最小化和全屏按钮，并设置无边框窗口
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.styleMask = [.borderless, .fullSizeContentView]
                window.level = .modalPanel
                window.collectionBehavior = [.stationary, .canJoinAllSpaces, .fullScreenAuxiliary]
                window.isMovable = false
                window.setFrame(NSScreen.main?.visibleFrame ?? .zero, display: true)
                
                // 设置半透明黑色背景
                window.backgroundColor = .clear // 改为清透背景
                window.isOpaque = false
                window.hasShadow = false
                window.ignoresMouseEvents = false // 确保能接收鼠标事件
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 确保窗口覆盖屏幕但不遮盖 Dock
                    DispatchQueue.main.async {
                        if let window = NSApplication.shared.windows.first {
                            window.styleMask = [.borderless, .fullSizeContentView]
                            window.setFrame(NSScreen.main?.visibleFrame ?? .zero, display: true) // 使用 visibleFrame
                        }
                    }
                }
        }
    }
}
