import Foundation

public struct AIJobInput: Equatable, Sendable {
    public let workType: String
    public let voltageLevel: String
    public let environment: [String]
    public let crewSize: Int
    public let equipment: [String]
    public let timePressure: String
    public let fatigueRisk: Bool
    public let newCrewMember: Bool

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
}
