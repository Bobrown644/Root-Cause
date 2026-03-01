import Foundation

public struct WhyEntry: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let depth: Int
    public var answer: String
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        depth: Int,
        answer: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.depth = depth
        self.answer = answer
        self.createdAt = createdAt
    }

    public var question: String {
        "Why #\(depth)?"
    }
}
