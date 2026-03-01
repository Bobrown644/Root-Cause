import Foundation

public enum AnalysisCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case engineering
    case process
    case people
    case tooling
    case communication
    case other

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .engineering: return "Engineering"
        case .process: return "Process"
        case .people: return "People"
        case .tooling: return "Tooling"
        case .communication: return "Communication"
        case .other: return "Other"
        }
    }

    public var iconName: String {
        switch self {
        case .engineering: return "wrench.and.screwdriver"
        case .process: return "arrow.triangle.branch"
        case .people: return "person.2"
        case .tooling: return "hammer"
        case .communication: return "bubble.left.and.bubble.right"
        case .other: return "questionmark.circle"
        }
    }
}
