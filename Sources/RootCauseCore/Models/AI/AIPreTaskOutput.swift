import Foundation

public struct AIPreTaskOutput: Codable, Equatable, Sendable {
    public let jobSummary: AIJobSummary
    public let fatal3: [AIFatalExposure]
    public let primaryEnergySources: [AIPrimaryEnergySource]
    public let topHazards: [AIHazard]
    public let humanPerformance: AIHumanPerformance
    public let briefScript: AIBriefScript

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case jobSummary = "job_summary"
        case fatal3
        case primaryEnergySources = "primary_energy_sources"
        case topHazards = "top_hazards"
        case humanPerformance = "human_performance"
        case briefScript = "brief_script"
    }

    public init(
        jobSummary: AIJobSummary,
        fatal3: [AIFatalExposure],
        primaryEnergySources: [AIPrimaryEnergySource],
        topHazards: [AIHazard],
        humanPerformance: AIHumanPerformance,
        briefScript: AIBriefScript
    ) {
        self.jobSummary = jobSummary
        self.fatal3 = fatal3
        self.primaryEnergySources = primaryEnergySources
        self.topHazards = topHazards
        self.humanPerformance = humanPerformance
        self.briefScript = briefScript
    }

    public init(from decoder: Decoder) throws {
        try decoder.rejectUnknownKeys(for: CodingKeys.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jobSummary = try container.decode(AIJobSummary.self, forKey: .jobSummary)
        fatal3 = try container.decode([AIFatalExposure].self, forKey: .fatal3)
        primaryEnergySources = try container.decode([AIPrimaryEnergySource].self, forKey: .primaryEnergySources)
        topHazards = try container.decode([AIHazard].self, forKey: .topHazards)
        humanPerformance = try container.decode(AIHumanPerformance.self, forKey: .humanPerformance)
        briefScript = try container.decode(AIBriefScript.self, forKey: .briefScript)
    }
}
