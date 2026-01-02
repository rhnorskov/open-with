import SwiftUI
import UniformTypeIdentifiers

extension String {
    func fuzzyMatch(_ needle: String) -> Bool {
        if needle.isEmpty { return true }
        var remainder = needle[...]
        for char in self {
            if char == remainder[remainder.startIndex] {
                remainder.removeFirst()
                if remainder.isEmpty { return true }
            }
        }
        return false
    }
}

enum FilterOption: String, CaseIterable, Identifiable {
    case all = "All"
    case noDefault = "No Default"
    case documents = "Documents"
    case code = "Code"
    case images = "Images"
    case audio = "Audio"
    case video = "Video"
    case archives = "Archives"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .noDefault: return "questionmark.circle"
        case .documents: return "doc.text"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .images: return "photo"
        case .audio: return "speaker.wave.2"
        case .video: return "film"
        case .archives: return "archivebox"
        }
    }

    var parentTypes: [UTType] {
        switch self {
        case .all, .noDefault: return []
        case .documents: return [.pdf, .presentation, .spreadsheet, .text]
        case .code: return [.sourceCode]
        case .images: return [.image]
        case .audio: return [.audio]
        case .video: return [.movie, .video]
        case .archives: return [.archive]
        }
    }

    func matches(_ utType: UTType?) -> Bool {
        guard let utType else { return false }
        return parentTypes.contains { utType.conforms(to: $0) }
    }
}

enum SidebarSelection: Hashable {
    case filter(FilterOption)
    case app(String) // bundle ID
}

struct ContentView: View {
    @StateObject private var viewModel = FileTypesViewModel()
    @State private var searchText = ""
    @State private var selection: SidebarSelection? = .filter(.all)
    @State private var showingAddSheet = false
    @State private var newExtension = ""

    var uniqueApps: [AppInfo] {
        let apps = viewModel.fileTypes.compactMap { $0.defaultHandler }
        var seen = Set<String>()
        return apps.filter { seen.insert($0.bundleId).inserted }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var filteredFileTypes: [FileTypeInfo] {
        var result = viewModel.fileTypes

        // Apply selection filter
        if let selection {
            switch selection {
            case .filter(let filter):
                switch filter {
                case .all:
                    break
                case .noDefault:
                    result = result.filter { $0.defaultHandler == nil }
                default:
                    result = result.filter { filter.matches($0.utType) }
                }
            case .app(let bundleId):
                result = result.filter { $0.defaultHandler?.bundleId == bundleId }
            }
        }

        // Apply search filter
        if !searchText.isEmpty {
            var query = searchText.lowercased()
            if query.hasPrefix(".") {
                query = String(query.dropFirst())
            }
            result = result.filter {
                $0.fileExtension.lowercased().fuzzyMatch(query) ||
                $0.uti.lowercased().fuzzyMatch(query) ||
                ($0.defaultHandler?.name.lowercased().fuzzyMatch(query) ?? false)
            }
        }

        return result
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selection) {
                Section("Filters") {
                    ForEach(FilterOption.allCases) { filter in
                        Label(filter.rawValue, systemImage: filter.icon)
                            .tag(SidebarSelection.filter(filter))
                    }
                }

                Section("Applications") {
                    ForEach(uniqueApps) { app in
                        HStack(spacing: 8) {
                            Image(nsImage: app.icon)
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text(app.name)
                                .lineLimit(1)
                        }
                        .tag(SidebarSelection.app(app.bundleId))
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            // Main content
            VStack(spacing: 0) {
                // File types list
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading file types...")
                    Spacer()
                } else if filteredFileTypes.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "doc.questionmark")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("No file types found")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredFileTypes) { fileType in
                                FileTypeRow(
                                    fileType: fileType,
                                    availableHandlers: viewModel.handlers[fileType.uti] ?? [],
                                    onLoadHandlers: {
                                        viewModel.loadHandlers(for: fileType.uti)
                                    },
                                    onHandlerSelected: { handler in
                                        viewModel.setHandler(handler, for: fileType)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .frame(minWidth: 500, minHeight: 400)
            .searchable(text: $searchText, prompt: "Search extensions or apps...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                    .help("Add custom extension")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { viewModel.refresh() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .help("Refresh list")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddExtensionSheet(
                extensionText: $newExtension,
                onAdd: {
                    viewModel.addCustomExtension(newExtension)
                    newExtension = ""
                    showingAddSheet = false
                },
                onCancel: {
                    newExtension = ""
                    showingAddSheet = false
                }
            )
        }
    }
}

struct AddExtensionSheet: View {
    @Binding var extensionText: String
    let onAdd: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Add Custom Extension")
                .font(.headline)

            TextField("Extension (e.g., txt, js, py)", text: $extensionText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)

            HStack {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                    .buttonStyle(.glass)

                Button("Add", action: onAdd)
                    .keyboardShortcut(.defaultAction)
                    .disabled(extensionText.isEmpty)
                    .buttonStyle(.glass)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

// MARK: - ViewModel

@MainActor
class FileTypesViewModel: ObservableObject {
    @Published var fileTypes: [FileTypeInfo] = []
    @Published var handlers: [String: [AppInfo]] = [:]
    @Published var isLoading = true

    private let handlerService = HandlerService.shared

    init() {
        refresh()
    }

    func refresh() {
        isLoading = true
        let service = handlerService

        Task {
            let types = await Task.detached {
                let extensions = service.discoverAllExtensions().sorted()
                var types = extensions.map { FileTypeInfo(fileExtension: $0) }

                for i in types.indices {
                    if let handler = service.getDefaultHandler(for: types[i].fileExtension) {
                        types[i].defaultHandler = handler
                    }
                }
                return types
            }.value

            self.fileTypes = types
            self.isLoading = false
        }
    }

    func loadHandlers(for uti: String) {
        guard handlers[uti] == nil else { return }
        let available = handlerService.getAllHandlers(for: uti)
        handlers[uti] = available
    }

    func setHandler(_ handler: AppInfo, for fileType: FileTypeInfo) {
        let success = handlerService.setDefaultHandler(
            bundleId: handler.bundleId,
            for: fileType.fileExtension
        )

        if success {
            if let index = fileTypes.firstIndex(where: { $0.fileExtension == fileType.fileExtension }) {
                fileTypes[index].defaultHandler = handler
            }
        }
    }

    func addCustomExtension(_ ext: String) {
        let cleanExt = ext.hasPrefix(".") ? String(ext.dropFirst()) : ext
        guard !cleanExt.isEmpty else { return }
        guard !fileTypes.contains(where: { $0.fileExtension == cleanExt }) else { return }

        var newType = FileTypeInfo(fileExtension: cleanExt)
        newType.defaultHandler = handlerService.getDefaultHandler(for: cleanExt)

        let available = handlerService.getAllHandlers(for: newType.uti)
        handlers[newType.uti] = available

        fileTypes.append(newType)
        fileTypes.sort { $0.fileExtension < $1.fileExtension }
    }
}
