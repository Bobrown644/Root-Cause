import Foundation

public struct AIBriefScript: Codable, Equatable, Sendable {
    public let opening: String
    public let keyQuestions: String
    public let closing: String

    public init(opening: String, keyQuestions: String, closing: String) {
        self.opening = opening
        self.keyQuestions = keyQuestions
        self.closing = closing
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        guard container.count == 3 else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: container.codingPath,
                debugDescription: "brief_script must contain exactly 3 elements, got \(container.count ?? 0)"
            ))
        }
        opening = try container.decode(String.self)
        keyQuestions = try container.decode(String.self)
        closing = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(opening)
        try container.encode(keyQuestions)
        try container.encode(closing)
    }
}
