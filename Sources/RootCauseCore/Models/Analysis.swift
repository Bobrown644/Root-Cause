import Foundation

public struct Analysis: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var category: AnalysisCategory
    public var status: AnalysisStatus
    public var whyEntries: [WhyEntry]
    public var rootCause: String?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        category: AnalysisCategory,
        status: AnalysisStatus = .inProgress,
        whyEntries: [WhyEntry] = [],
        rootCause: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.status = status
        self.whyEntries = whyEntries
        self.rootCause = rootCause
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var currentDepth: Int {
        whyEntries.count
    }

    public var isComplete: Bool {
        status == .completed
    }

    public mutating func addWhy(answer: String) {
        let entry = WhyEntry(depth: currentDepth + 1, answer: answer)
        whyEntries.append(entry)
        updatedAt = Date()
    }

    public mutating func complete(with rootCause: String) {
        self.rootCause = rootCause
        self.status = .completed
        self.updatedAt = Date()
    }

    public mutating func reopen() {
        self.rootCause = nil
        self.status = .inProgress
        self.updatedAt = Date()
    }
}
