import Foundation
import UniformTypeIdentifiers

struct FileTypeInfo: Identifiable, Hashable {
    let id = UUID()
    let fileExtension: String
    let uti: String
    let utType: UTType?
    let displayName: String
    var defaultHandler: AppInfo?

    init(fileExtension: String, uti: String? = nil, displayName: String? = nil) {
        self.fileExtension = fileExtension

        if let uti = uti {
            self.uti = uti
            self.utType = UTType(uti)
        } else if let utType = UTType(filenameExtension: fileExtension) {
            self.uti = utType.identifier
            self.utType = utType
        } else {
            self.uti = "dyn.\(fileExtension)"
            self.utType = nil
        }

        self.displayName = displayName ?? fileExtension.uppercased()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileExtension)
    }

    static func == (lhs: FileTypeInfo, rhs: FileTypeInfo) -> Bool {
        lhs.fileExtension == rhs.fileExtension
    }
}
