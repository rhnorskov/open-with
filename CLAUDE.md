# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the project
swift build

# Build for release
swift build -c release

# Run the app
swift run

# Clean build artifacts
swift package clean
```

## Project Overview

OpenWith is a macOS SwiftUI application that provides a graphical interface for managing file type associations. It allows users to view, search, and change the default application handlers for file extensions.

**Requirements:**
- macOS 26+ (Swift 6.2, Swift Package Manager)

## Architecture

```
OpenWith/
├── OpenWithApp.swift       # App entry point with AppDelegate
├── ContentView.swift       # Main view with sidebar filters + file type list + ViewModel
├── Models/
│   ├── AppInfo.swift       # Application metadata (bundle ID, name, icon)
│   └── FileTypeInfo.swift  # File extension + UTI + handler info
├── Views/
│   └── FileTypeRow.swift   # Individual file type row with handler picker
└── Services/
    └── HandlerService.swift # Launch Services API wrapper
```

**Key patterns:**
- `HandlerService` uses native Launch Services APIs (LSCopyDefaultRoleHandlerForContentType, etc.)
- `FileTypesViewModel` in ContentView.swift manages state and async loading
- Sidebar filters use UTI hierarchy (public.image, public.source-code, etc.)
- Handlers are lazy-loaded on hover for each file type row
- Uses macOS 26 glass effects (`.glassEffect()`)
