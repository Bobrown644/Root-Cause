import XCTest
@testable import RootCauseCore

final class AIHazardServiceTests: XCTestCase {

    let sampleTemplate = """
    JOB INPUTS:
    work_type: {{work_type}}
    voltage_level: {{voltage_level}}
    environment: {{environment_csv}}
    crew_size: {{crew_size}}
    equipment: {{equipment_csv}}
    time_pressure: {{time_pressure}}
    fatigue_risk: {{fatigue_risk}}
    new_crew_member: {{new_crew_member}}

    TASK: Return JSON.
    """

    let sampleInput = AIJobInput(
        workType: "Line Stringing",
        voltageLevel: "345kV",
        environment: ["Rural", "Adjacent Energized"],
        crewSize: 8,
        equipment: ["Tensioner", "Puller", "Bucket Truck"],
        timePressure: "Moderate",
        fatigueRisk: false,
        newCrewMember: true
    )

    // MARK: - Prompt building

    func testBuildUserPromptSubstitutesAllPlaceholders() {
        let client = MockAIClient()
        let service = AIHazardService(
            systemPrompt: "system",
            userPromptTemplate: sampleTemplate,
            client: client
        )

        let result = service.buildUserPrompt(for: sampleInput)

        XCTAssertTrue(result.contains("Line Stringing"))
        XCTAssertTrue(result.contains("345kV"))
        XCTAssertTrue(result.contains("Rural, Adjacent Energized"))
        XCTAssertTrue(result.contains("8"))
        XCTAssertTrue(result.contains("Tensioner, Puller, Bucket Truck"))
        XCTAssertTrue(result.contains("Moderate"))
        XCTAssertTrue(result.contains("false"))
        XCTAssertTrue(result.contains("true"))

        XCTAssertFalse(result.contains("{{"))
        XCTAssertFalse(result.contains("}}"))
    }

    // MARK: - End-to-end with mock client

    func testGeneratePreTaskOutputWithMockClient() async throws {
        let client = MockAIClient()
        let service = AIHazardService(
            systemPrompt: "system prompt here",
            userPromptTemplate: sampleTemplate,
            client: client
        )

        let output = try await service.generatePreTaskOutput(for: sampleInput)

        XCTAssertEqual(client.callCount, 1)
        XCTAssertEqual(client.lastSystemPrompt, "system prompt here")
        XCTAssertNotNil(client.lastUserPrompt)
        XCTAssertTrue(client.lastUserPrompt!.contains("Line Stringing"))

        XCTAssertEqual(output.jobSummary.workType, "Line Stringing")
        XCTAssertEqual(output.fatal3.count, 3)
        XCTAssertEqual(output.primaryEnergySources.count, 3)
        XCTAssertEqual(output.topHazards.count, 5)
        XCTAssertEqual(output.humanPerformance.stopWorkTriggers.count, 4)
        XCTAssertFalse(output.briefScript.opening.isEmpty)
    }

    // MARK: - Error handling

    func testEmptyResponseThrows() async {
        let client = MockAIClient(fixtureJSON: "   ")
        let service = AIHazardService(
            systemPrompt: "",
            userPromptTemplate: sampleTemplate,
            client: client
        )

        do {
            _ = try await service.generatePreTaskOutput(for: sampleInput)
            XCTFail("Expected error for empty response")
        } catch let error as AIClientError {
            if case .emptyResponse = error {
                // expected
            } else {
                XCTFail("Expected emptyResponse, got \(error)")
            }
        } catch {
            XCTFail("Expected AIClientError, got \(error)")
        }
    }

    func testMalformedJSONThrows() async {
        let client = MockAIClient(fixtureJSON: "{ not valid json !!!")
        let service = AIHazardService(
            systemPrompt: "",
            userPromptTemplate: sampleTemplate,
            client: client
        )

        do {
            _ = try await service.generatePreTaskOutput(for: sampleInput)
            XCTFail("Expected error for malformed JSON")
        } catch let error as AIClientError {
            if case .invalidJSON = error {
                // expected
            } else {
                XCTFail("Expected invalidJSON, got \(error)")
            }
        } catch {
            XCTFail("Expected AIClientError, got \(error)")
        }
    }

    func testExtraKeysInResponseThrows() async {
        let badJSON = """
        {
          "job_summary": {
            "work_type": "X", "voltage_level": "X", "environment": [],
            "crew_size": 1, "equipment": [], "time_pressure": "None",
            "fatigue_risk": false, "new_crew_member": false
          },
          "fatal3": [],
          "primary_energy_sources": [],
          "top_hazards": [],
          "human_performance": {
            "error_precursors": [], "likely_traps": [],
            "countermeasures": [], "stop_work_triggers": []
          },
          "brief_script": ["a", "b", "c"],
          "rogue_key": "should reject"
        }
        """
        let client = MockAIClient(fixtureJSON: badJSON)
        let service = AIHazardService(
            systemPrompt: "",
            userPromptTemplate: sampleTemplate,
            client: client
        )

        do {
            _ = try await service.generatePreTaskOutput(for: sampleInput)
            XCTFail("Expected error for extra keys in JSON")
        } catch let error as AIClientError {
            if case .invalidJSON = error {
                // expected — strict decoding rejects the extra key
            } else {
                XCTFail("Expected invalidJSON, got \(error)")
            }
        } catch {
            XCTFail("Expected AIClientError, got \(error)")
        }
    }

    // MARK: - Multiple calls

    func testMultipleCallsTrackCount() async throws {
        let client = MockAIClient()
        let service = AIHazardService(
            systemPrompt: "",
            userPromptTemplate: sampleTemplate,
            client: client
        )

        _ = try await service.generatePreTaskOutput(for: sampleInput)
        _ = try await service.generatePreTaskOutput(for: sampleInput)

        XCTAssertEqual(client.callCount, 2)
    }
}
