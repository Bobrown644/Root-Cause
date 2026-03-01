import Foundation

public struct AIHazard: Codable, Equatable, Sendable {
    public let hazard: String
    public let lineOfFire: Bool
    public let likelihood: String
    public let severity: String
    public let controls: [String]
    public let verification: [String]

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case hazard
        case lineOfFire = "line_of_fire"
        case likelihood
        case severity
        case controls
        case verification
    }

    public init(
        hazard: String,
        lineOfFire: Bool,
        likelihood: String,
        severity: String,
        controls: [String],
        verification: [String]
    ) {
        self.hazard = hazard
        self.lineOfFire = lineOfFire
        self.likelihood = likelihood
        self.severity = severity
        self.controls = controls
        self.verification = verification
    }

    public init(from decoder: Decoder) throws {
        try decoder.rejectUnknownKeys(for: CodingKeys.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hazard = try container.decode(String.self, forKey: .hazard)
        lineOfFire = try container.decode(Bool.self, forKey: .lineOfFire)
        likelihood = try container.decode(String.self, forKey: .likelihood)
        severity = try container.decode(String.self, forKey: .severity)
        controls = try container.decode([String].self, forKey: .controls)
        verification = try container.decode([String].self, forKey: .verification)
    }
}
