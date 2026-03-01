import Foundation

public struct AIPrimaryEnergySource: Codable, Equatable, Sendable {
    public let type: String
    public let examples: [String]
    public let controls: [String]

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case type
        case examples
        case controls
    }

    public init(type: String, examples: [String], controls: [String]) {
        self.type = type
        self.examples = examples
        self.controls = controls
    }

    public init(from decoder: Decoder) throws {
        try decoder.rejectUnknownKeys(for: CodingKeys.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        examples = try container.decode([String].self, forKey: .examples)
        controls = try container.decode([String].self, forKey: .controls)
    }
}
