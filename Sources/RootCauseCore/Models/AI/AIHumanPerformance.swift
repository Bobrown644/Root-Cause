import Foundation

public struct AIHumanPerformance: Codable, Equatable, Sendable {
    public let errorPrecursors: [String]
    public let likelyTraps: [String]
    public let countermeasures: [String]
    public let stopWorkTriggers: [String]

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case errorPrecursors = "error_precursors"
        case likelyTraps = "likely_traps"
        case countermeasures
        case stopWorkTriggers = "stop_work_triggers"
    }

    public init(
        errorPrecursors: [String],
        likelyTraps: [String],
        countermeasures: [String],
        stopWorkTriggers: [String]
    ) {
        self.errorPrecursors = errorPrecursors
        self.likelyTraps = likelyTraps
        self.countermeasures = countermeasures
        self.stopWorkTriggers = stopWorkTriggers
    }

    public init(from decoder: Decoder) throws {
        try decoder.rejectUnknownKeys(for: CodingKeys.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        errorPrecursors = try container.decode([String].self, forKey: .errorPrecursors)
        likelyTraps = try container.decode([String].self, forKey: .likelyTraps)
        countermeasures = try container.decode([String].self, forKey: .countermeasures)
        stopWorkTriggers = try container.decode([String].self, forKey: .stopWorkTriggers)
    }
}
