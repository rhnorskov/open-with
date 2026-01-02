import SwiftUI

struct FileTypeRow: View {
    let fileType: FileTypeInfo
    let availableHandlers: [AppInfo]
    let onLoadHandlers: () -> Void
    let onHandlerSelected: (AppInfo) -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            // Extension icon
            FileIconView(fileExtension: fileType.fileExtension)
                .frame(width: 36, height: 36)

            // Extension info
            VStack(alignment: .leading, spacing: 2) {
                Text(".\(fileType.fileExtension)")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)

                Text(fileType.uti)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Current handler / picker
            Menu {
                if availableHandlers.isEmpty {
                    Text("No registered apps")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(availableHandlers) { handler in
                        Button(action: { onHandlerSelected(handler) }) {
                            HStack {
                                Image(nsImage: handler.icon)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                Text(handler.name)

                                if handler.bundleId == fileType.defaultHandler?.bundleId {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    if let currentHandler = fileType.defaultHandler {
                        Image(nsImage: currentHandler.icon)
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(currentHandler.name)
                            .lineLimit(1)
                    } else {
                        Image(systemName: "app.dashed")
                            .frame(width: 20, height: 20)
                        Text("No default")
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            }
            .menuStyle(.borderlessButton)
            .glassEffect(.regular.interactive(), in: .capsule)
            .fixedSize()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(in: .rect(cornerRadius: 12))
        .onHover { hovering in
            isHovering = hovering
            if hovering {
                onLoadHandlers()
            }
        }
    }
}

struct FileIconView: View {
    let fileExtension: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(iconColor.gradient)

            Text(fileExtension.prefix(3).uppercased())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var iconColor: Color {
        switch fileExtension.lowercased() {
        // Code
        case "swift", "rs", "go", "java", "kt", "scala", "c", "cpp", "h":
            return .orange
        case "js", "ts", "jsx", "tsx":
            return .yellow
        case "py", "rb":
            return .blue
        case "html", "css", "scss", "sass", "less":
            return .pink
        case "json", "xml", "yaml", "yml":
            return .purple

        // Documents
        case "pdf":
            return .red
        case "doc", "docx", "txt", "rtf", "md":
            return .blue
        case "xls", "xlsx", "csv":
            return .green
        case "ppt", "pptx":
            return .orange

        // Media
        case "jpg", "jpeg", "png", "gif", "svg", "webp", "heic":
            return .teal
        case "mp3", "wav", "aac", "flac", "m4a":
            return .pink
        case "mp4", "mov", "avi", "mkv", "webm":
            return .indigo

        // Archives
        case "zip", "tar", "gz", "rar", "7z", "dmg":
            return .gray

        default:
            return .secondary
        }
    }
}
