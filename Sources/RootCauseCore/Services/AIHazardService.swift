import Foundation

public final class AIHazardService: @unchecked Sendable {
    private let systemPrompt: String
    private let userPromptTemplate: String
    private let client: any AIClient

    public init(systemPrompt: String, userPromptTemplate: String, client: any AIClient) {
        self.systemPrompt = systemPrompt
        self.userPromptTemplate = userPromptTemplate
        self.client = client
    }

    /// Loads prompt files from a Foundation `Bundle` (typically `Bundle.main` in-app).
    /// The bundle must contain `LineReadySystemPrompt.txt` and `LineReadyUserPromptTemplate.txt`.
    public static func bundled(from bundle: Bundle, client: any AIClient) throws -> AIHazardService {
        let systemPrompt = try Self.loadPrompt(named: "LineReadySystemPrompt", in: bundle)
        let template = try Self.loadPrompt(named: "LineReadyUserPromptTemplate", in: bundle)
        return AIHazardService(systemPrompt: systemPrompt, userPromptTemplate: template, client: client)
    }

    // MARK: - Generate

    public func generatePreTaskOutput(for input: AIJobInput) async throws -> AIPreTaskOutput {
        let userPrompt = buildUserPrompt(for: input)
        let raw = try await client.complete(systemPrompt: systemPrompt, userPrompt: userPrompt)

        guard !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIClientError.emptyResponse
        }

        guard let data = raw.data(using: .utf8) else {
            throw AIClientError.invalidJSON(
                underlying: NSError(domain: "AIHazardService", code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Response is not valid UTF-8"])
            )
        }

        do {
            return try JSONDecoder().decode(AIPreTaskOutput.self, from: data)
        } catch {
            throw AIClientError.invalidJSON(underlying: error)
        }
    }

    // MARK: - Prompt building

    func buildUserPrompt(for input: AIJobInput) -> String {
        var prompt = userPromptTemplate
        prompt = prompt.replacingOccurrences(of: "{{work_type}}", with: input.workType)
        prompt = prompt.replacingOccurrences(of: "{{voltage_level}}", with: input.voltageLevel)
        prompt = prompt.replacingOccurrences(of: "{{environment_csv}}", with: input.environment.joined(separator: ", "))
        prompt = prompt.replacingOccurrences(of: "{{crew_size}}", with: String(input.crewSize))
        prompt = prompt.replacingOccurrences(of: "{{equipment_csv}}", with: input.equipment.joined(separator: ", "))
        prompt = prompt.replacingOccurrences(of: "{{time_pressure}}", with: input.timePressure)
        prompt = prompt.replacingOccurrences(of: "{{fatigue_risk}}", with: input.fatigueRisk ? "true" : "false")
        prompt = prompt.replacingOccurrences(of: "{{new_crew_member}}", with: input.newCrewMember ? "true" : "false")
        return prompt
    }

    // MARK: - Bundle loading

    private static func loadPrompt(named name: String, in bundle: Bundle) throws -> String {
        guard let url = bundle.url(forResource: name, withExtension: "txt") else {
            throw AIHazardServiceError.promptFileNotFound(name)
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}

public enum AIHazardServiceError: Error, LocalizedError {
    case promptFileNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .promptFileNotFound(let name):
            return "Prompt file '\(name).txt' not found in bundle."
        }
    }
}
