import Foundation
import AppKit

struct AppInfo: Identifiable, Hashable {
    let id: String // bundle ID
    let bundleId: String
    let name: String
    let path: String?

    var icon: NSImage {
        if let path = path {
            return NSWorkspace.shared.icon(forFile: path)
        }
        return NSWorkspace.shared.icon(for: .application)
    }

    init(bundleId: String, name: String? = nil, path: String? = nil) {
        self.id = bundleId
        self.bundleId = bundleId
        self.path = path ?? NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)?.path

        if let name = name {
            self.name = name
        } else if let appPath = self.path {
            self.name = FileManager.default.displayName(atPath: appPath)
                .replacingOccurrences(of: ".app", with: "")
        } else {
            // Extract app name from bundle ID (e.g., com.apple.Safari -> Safari)
            self.name = bundleId.components(separatedBy: ".").last ?? bundleId
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleId)
    }

    static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        lhs.bundleId == rhs.bundleId
    }
}
