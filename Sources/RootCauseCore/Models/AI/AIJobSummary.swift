import Foundation

public struct AIJobSummary: Codable, Equatable, Sendable {
    public let workType: String
    public let voltageLevel: String
    public let environment: [String]
    public let crewSize: Int
    public let equipment: [String]
    public let timePressure: String
    public let fatigueRisk: Bool
    public let newCrewMember: Bool

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case workType = "work_type"
        case voltageLevel = "voltage_level"
        case environment
        case crewSize = "crew_size"
        case equipment
        case timePressure = "time_pressure"
        case fatigueRisk = "fatigue_risk"
        case newCrewMember = "new_crew_member"
    }

    public init(
        workType: String,
        voltageLevel: String,
        environment: [String],
        crewSize: Int,
        equipment: [String],
        timePressure: String,
        fatigueRisk: Bool,
        newCrewMember: Bool
    ) {
        self.workType = workType
        self.voltageLevel = voltageLevel
        self.environment = environment
        self.crewSize = crewSize
        self.equipment = equipment
        self.timePressure = timePressure
        self.fatigueRisk = fatigueRisk
        self.newCrewMember = newCrewMember
    }

    public init(from decoder: Decoder) throws {
        try decoder.rejectUnknownKeys(for: CodingKeys.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workType = try container.decode(String.self, forKey: .workType)
        voltageLevel = try container.decode(String.self, forKey: .voltageLevel)
        environment = try container.decode([String].self, forKey: .environment)
        crewSize = try container.decode(Int.self, forKey: .crewSize)
        equipment = try container.decode([String].self, forKey: .equipment)
        timePressure = try container.decode(String.self, forKey: .timePressure)
        fatigueRisk = try container.decode(Bool.self, forKey: .fatigueRisk)
        newCrewMember = try container.decode(Bool.self, forKey: .newCrewMember)
    }
}
