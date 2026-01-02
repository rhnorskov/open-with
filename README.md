# OpenWith

A macOS app for managing file type associations. View, search, and change default application handlers for file extensions.

![macOS 26+](https://img.shields.io/badge/macOS-26%2B-blue)
![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange)

## Features

- Browse all registered file extensions from Launch Services
- Filter by category (Documents, Code, Images, Audio, Video, Archives)
- Filter by application
- Fuzzy search for extensions, UTIs, or app names
- Change default handlers with a single click

## Installation

Download the latest DMG from [Releases](https://github.com/rhnorskov/open-with/releases), open it, and drag OpenWith to Applications.

### Gatekeeper Warning

Since the app isn't notarized, macOS may show a warning. To open it:

**Option 1:** Right-click the app and select "Open"

**Option 2:** Remove quarantine attribute:
```bash
xattr -cr /Applications/OpenWith.app
```

## Building from Source

Requires macOS 26+ and Swift 6.2.

```bash
# Clone
git clone https://github.com/rhnorskov/open-with.git
cd open-with

# Build
swift build -c release

# Run
swift run
```

## License

MIT
