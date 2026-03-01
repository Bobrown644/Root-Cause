# Root-Cause

A SwiftUI app for performing **Root Cause Analysis** using the **5 Whys** methodology. Built with the MVVM (Model-View-ViewModel) pattern.

## Features

- Create root cause analyses with problem statements and categories
- Walk through the 5 Whys methodology step by step
- Track progress with visual indicators
- Mark analyses as complete with root cause summaries
- Filter and search analyses by status and category
- Persistent JSON-based local storage

## Architecture

The project follows **MVVM** with a clear separation of concerns:

```
Sources/
├── RootCauseCore/          # Cross-platform library (models + services)
│   ├── Models/             # Data models (structs)
│   ├── Services/           # AnalysisStore (persistence)
│   └── Extensions/         # JSON coding helpers
└── RootCauseApp/           # SwiftUI app (Apple platforms)
    ├── App/                # @main entry point
    ├── ViewModels/         # ObservableObject view models
    └── Views/              # SwiftUI views + components
```

### Key Patterns

- **Structs** for all data models (`Analysis`, `WhyEntry`, `AnalysisCategory`)
- **ObservableObject** classes for ViewModels
- **lazy var** for expensive computed properties (e.g., `dateFormatter` in `AnalysisStore`)
- Protocol-based services (`AnalysisStoring`) for testability

## Requirements

- iOS 16+ / macOS 13+
- Swift 5.9+
- Xcode 15+

## Development

### Build the core library (cross-platform)

```bash
swift build
```

### Run tests

```bash
swift test
```

### Open in Xcode

Open `Package.swift` in Xcode for the full SwiftUI development experience with previews.

## Categories

Analyses can be categorized as: Engineering, Process, People, Tooling, Communication, or Other.
