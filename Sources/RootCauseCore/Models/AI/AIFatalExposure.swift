import Foundation

public struct AIFatalExposure: Codable, Equatable, Sendable {
    public let exposure: String
    public let whyItKills: String
    public let criticalControls: [String]

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case exposure
        case whyItKills = "why_it_kills"
        case criticalControls = "critical_controls"
    }

    public init(exposure: String, whyItKills: String, criticalControls: [String]) {
        self.exposure = exposure
        self.whyItKills = whyItKills
        self.criticalControls = criticalControls
    }

    public init(from decoder: Decoder) throws {
        try decoder.rejectUnknownKeys(for: CodingKeys.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        exposure = try container.decode(String.self, forKey: .exposure)
        whyItKills = try container.decode(String.self, forKey: .whyItKills)
        criticalControls = try container.decode([String].self, forKey: .criticalControls)
    }
}
