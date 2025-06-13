//
//  AppModel.swift
//  
//  Created by Chu Feng on 13/6/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct AppModel: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let displayName: String // Add localized display name
    let icon: NSImage
    let url: URL
    let folderName: String?
    var isFolder: Bool = false // New property, indicates if it's a folder
    var children: [AppModel]? = nil // If it's a folder, contains child applications

    static func == (lhs: AppModel, rhs: AppModel) -> Bool {
        lhs.id == rhs.id
    }

    mutating func addToFolder(_ app: AppModel) {
        if children == nil {
            children = []
        }
        children?.append(app)
    }
}

func createFolder(name: String, apps: [AppModel]) -> AppModel {
    let icon = NSWorkspace.shared.icon(for: UTType.folder)
    icon.size = NSSize(width: 64, height: 64)
    return AppModel(
        name: name,
        displayName: name,
        icon: icon,
        url: URL(fileURLWithPath: ""),
        folderName: name,
        isFolder: true,
        children: apps
    )
}

func fetchApplications() -> [AppModel] {
    let fileManager = FileManager.default
    let workspace = NSWorkspace.shared
    let applicationDirectories = [
        "/Applications",
        "/System/Applications",
        NSHomeDirectory() + "/Applications"
    ]
    var apps: [AppModel] = []

    for path in applicationDirectories {
        let directoryURL = URL(fileURLWithPath: path)
        guard let appURLs = try? fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [.isApplicationKey],
            options: .skipsHiddenFiles
        ) else { continue }

        for appURL in appURLs {
            guard appURL.pathExtension == "app" else { continue }
            
            // Get application bundle
            guard let bundle = Bundle(url: appURL) else { continue }
            
            // Get localized display name
            let appName = bundle.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                         bundle.localizedInfoDictionary?["CFBundleName"] as? String ??
                         bundle.infoDictionary?["CFBundleDisplayName"] as? String ??
                         bundle.infoDictionary?["CFBundleName"] as? String ??
                         fileManager.displayName(atPath: appURL.path)
            
            let appIcon = workspace.icon(forFile: appURL.path)
            appIcon.size = NSSize(width: 64, height: 64)

            let app = AppModel(
                name: fileManager.displayName(atPath: appURL.path),
                displayName: appName,
                icon: appIcon,
                url: appURL,
                folderName: nil
            )
            apps.append(app)
        }
    }

    return apps.sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
}

extension AppModel {
    /// Returns the localized name for the app if available, otherwise falls back to the default name.
    func localizedName(for languageCode: String?) -> String {
        // If you have a localization dictionary, use it here. For now, just return name.
        // You can extend this to support more languages if you have the data.
        return name
    }
}
