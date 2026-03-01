# AGENTS.md

## Cursor Cloud specific instructions

**Root-Cause** is a SwiftUI app for root cause analysis using the 5 Whys methodology. It follows the MVVM pattern with `ObservableObject`.

### Project structure

- `RootCauseCore` — Cross-platform Swift library containing models and services. Builds and tests on Linux.
- `RootCauseApp` — SwiftUI app target (Apple platforms only). Views and ViewModels are guarded with `#if canImport(SwiftUI)`.

### Build and test (Linux)

```bash
swift build           # Builds RootCauseCore only (SwiftUI code is conditionally compiled out)
swift test            # Runs 27 unit tests for models and AnalysisStore
```

### Caveats

- Swift is installed at `/opt/swift/usr/bin`. The PATH must include it: `export PATH=/opt/swift/usr/bin:$PATH` (already in `~/.bashrc`).
- SwiftUI/Combine are not available on Linux. Only `RootCauseCore` (models, services, extensions) compiles on Linux. The `Sources/RootCauseApp/` directory is **not** a Package.swift target — it exists for Xcode on macOS.
- The `AnalysisStore` uses a platform-conditional default path (`~/Documents/RootCause/` on Linux, `documentDirectory` on Apple). Tests use a temp directory.
- The `Package.swift` specifies `.iOS(.v16)` and `.macOS(.v13)` platform minimums, which only affects Apple builds; Linux builds ignore `platforms`.
