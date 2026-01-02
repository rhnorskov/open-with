import Foundation
import CoreServices
import UniformTypeIdentifiers

final class HandlerService: @unchecked Sendable {
    static let shared = HandlerService()

    // MARK: - Public API

    /// Get the default handler for a file extension
    func getDefaultHandler(for ext: String) -> AppInfo? {
        guard let utType = UTType(filenameExtension: ext) else { return nil }

        guard let handlerRef = LSCopyDefaultRoleHandlerForContentType(
            utType.identifier as CFString,
            .all
        ) else { return nil }

        let bundleId = handlerRef.takeRetainedValue() as String
        return AppInfo(bundleId: bundleId)
    }

    /// Get all handlers that can open a given UTI
    func getAllHandlers(for uti: String) -> [AppInfo] {
        guard let handlersRef = LSCopyAllRoleHandlersForContentType(
            uti as CFString,
            .all
        ) else { return [] }

        let handlers = handlersRef.takeRetainedValue() as? [String] ?? []
        return handlers.map { AppInfo(bundleId: $0) }
    }

    /// Set the default handler for a file extension
    func setDefaultHandler(bundleId: String, for ext: String) -> Bool {
        guard let utType = UTType(filenameExtension: ext) else { return false }

        let result = LSSetDefaultRoleHandlerForContentType(
            utType.identifier as CFString,
            .all,
            bundleId as CFString
        )

        return result == noErr
    }

    /// Discover all extensions registered in Launch Services
    func discoverAllExtensions() -> Set<String> {
        let lsregisterPath = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
        let result = shell("\(lsregisterPath) -dump 2>/dev/null | grep 'tags:' | sed 's/tags://' | tr ',' '\\n' | grep -E '^\\s*\\.[a-zA-Z0-9]+$' | sed 's/^[[:space:]]*//' | sed 's/^\\.//' | sort -u")

        guard result.exitCode == 0 else { return [] }

        let extensions = result.output
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .filter { !$0.isEmpty && $0.count <= 10 }

        return Set(extensions)
    }

    // MARK: - Private

    private func shell(_ command: String) -> (output: String, exitCode: Int32) {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            return ("Error: \(error.localizedDescription)", 1)
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        return (output.trimmingCharacters(in: .whitespacesAndNewlines), task.terminationStatus)
    }
}
