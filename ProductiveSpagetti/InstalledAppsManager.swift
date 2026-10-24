//
//  InstalledAppsManager.swift
//  ProductiveSpagetti
//
//  Created by Liam Gao on 8/18/26.
//

import Foundation

struct InstalledApp: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: URL
}

final class InstalledAppsManager {

    static let shared = InstalledAppsManager()

    private init() {}

    func getInstalledApps() -> [InstalledApp] {

        let fileManager = FileManager.default

        let folders = [
            "/Applications",
            "/System/Applications",
            "/System/Applications/Utilities",
            "\(NSHomeDirectory())/Applications"
        ]

        var apps: [InstalledApp] = []

        for folder in folders {

            let folderURL = URL(fileURLWithPath: folder)

            guard let contents = try? fileManager.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else {
                continue
            }

            for url in contents {

                guard url.pathExtension == "app" else {
                    continue
                }

                let name = url.deletingPathExtension().lastPathComponent

                if !apps.contains(where: { $0.name == name }) {
                    apps.append(
                        InstalledApp(
                            name: name,
                            path: url
                        )
                    )
                }
            }
        }

        return apps.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name)
                == .orderedAscending
        }
    }
}
