import XCTest
@testable import RootCauseCore

final class AIModelDecodingTests: XCTestCase {

    // MARK: - Full round-trip

    func testDecodeDefaultFixture() throws {
        let data = MockAIClient.defaultFixture.data(using: .utf8)!
        let output = try JSONDecoder().decode(AIPreTaskOutput.self, from: data)

        XCTAssertEqual(output.jobSummary.workType, "Line Stringing")
        XCTAssertEqual(output.jobSummary.voltageLevel, "345kV")
        XCTAssertEqual(output.jobSummary.environment, ["Rural", "Adjacent Energized"])
        XCTAssertEqual(output.jobSummary.crewSize, 8)
        XCTAssertEqual(output.jobSummary.equipment, ["Tensioner", "Puller", "Bucket Truck"])
        XCTAssertEqual(output.jobSummary.timePressure, "Moderate")
        XCTAssertFalse(output.jobSummary.fatigueRisk)
        XCTAssertTrue(output.jobSummary.newCrewMember)

        XCTAssertEqual(output.fatal3.count, 3)
        XCTAssertFalse(output.fatal3[0].exposure.isEmpty)
        XCTAssertFalse(output.fatal3[0].whyItKills.isEmpty)
        XCTAssertEqual(output.fatal3[0].criticalControls.count, 3)

        XCTAssertEqual(output.primaryEnergySources.count, 3)
        XCTAssertEqual(output.primaryEnergySources[0].type, "Electrical")

        XCTAssertEqual(output.topHazards.count, 5)
        XCTAssertTrue(output.topHazards[0].lineOfFire)
        XCTAssertEqual(output.topHazards[0].likelihood, "High")
        XCTAssertEqual(output.topHazards[0].severity, "Fatal")
        XCTAssertGreaterThanOrEqual(output.topHazards[0].verification.count, 1)

        XCTAssertEqual(output.humanPerformance.errorPrecursors.count, 3)
        XCTAssertEqual(output.humanPerformance.likelyTraps.count, 3)
        XCTAssertEqual(output.humanPerformance.countermeasures.count, 3)
        XCTAssertEqual(output.humanPerformance.stopWorkTriggers.count, 4)

        XCTAssertFalse(output.briefScript.opening.isEmpty)
        XCTAssertFalse(output.briefScript.keyQuestions.isEmpty)
        XCTAssertFalse(output.briefScript.closing.isEmpty)
    }

    func testEncodeDecodeRoundTrip() throws {
        let data = MockAIClient.defaultFixture.data(using: .utf8)!
        let original = try JSONDecoder().decode(AIPreTaskOutput.self, from: data)
        let reEncoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AIPreTaskOutput.self, from: reEncoded)
        XCTAssertEqual(original, decoded)
    }

    // MARK: - Strict decoding rejects extra keys

    func testRejectsExtraRootKey() {
        let json = """
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
          "bogus_key": "should fail"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(AIPreTaskOutput.self, from: json)) { error in
            guard case DecodingError.dataCorrupted(let ctx) = error else {
                XCTFail("Expected dataCorrupted, got \(error)")
                return
            }
            XCTAssertTrue(ctx.debugDescription.contains("bogus_key"))
        }
    }

    func testRejectsExtraJobSummaryKey() {
        let json = """
        {
          "job_summary": {
            "work_type": "X", "voltage_level": "X", "environment": [],
            "crew_size": 1, "equipment": [], "time_pressure": "None",
            "fatigue_risk": false, "new_crew_member": false,
            "extra_field": true
          },
          "fatal3": [],
          "primary_energy_sources": [],
          "top_hazards": [],
          "human_performance": {
            "error_precursors": [], "likely_traps": [],
            "countermeasures": [], "stop_work_triggers": []
          },
          "brief_script": ["a", "b", "c"]
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(AIPreTaskOutput.self, from: json)) { error in
            guard case DecodingError.dataCorrupted(let ctx) = error else {
                XCTFail("Expected dataCorrupted, got \(error)")
                return
            }
            XCTAssertTrue(ctx.debugDescription.contains("extra_field"))
        }
    }

    func testRejectsExtraHazardKey() {
        let json = """
        {
          "job_summary": {
            "work_type": "X", "voltage_level": "X", "environment": [],
            "crew_size": 1, "equipment": [], "time_pressure": "None",
            "fatigue_risk": false, "new_crew_member": false
          },
          "fatal3": [],
          "primary_energy_sources": [],
          "top_hazards": [
            {
              "hazard": "X", "line_of_fire": true, "likelihood": "High",
              "severity": "Fatal", "controls": [], "verification": [],
              "notes": "extra"
            }
          ],
          "human_performance": {
            "error_precursors": [], "likely_traps": [],
            "countermeasures": [], "stop_work_triggers": []
          },
          "brief_script": ["a", "b", "c"]
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(AIPreTaskOutput.self, from: json)) { error in
            guard case DecodingError.dataCorrupted(let ctx) = error else {
                XCTFail("Expected dataCorrupted, got \(error)")
                return
            }
            XCTAssertTrue(ctx.debugDescription.contains("notes"))
        }
    }

    // MARK: - Strict decoding rejects missing keys

    func testRejectsMissingJobSummaryKey() {
        let json = """
        {
          "job_summary": {
            "work_type": "X", "voltage_level": "X", "environment": [],
            "crew_size": 1, "equipment": [], "time_pressure": "None",
            "fatigue_risk": false
          },
          "fatal3": [],
          "primary_energy_sources": [],
          "top_hazards": [],
          "human_performance": {
            "error_precursors": [], "likely_traps": [],
            "countermeasures": [], "stop_work_triggers": []
          },
          "brief_script": ["a", "b", "c"]
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(AIPreTaskOutput.self, from: json))
    }

    // MARK: - AIBriefScript

    func testBriefScriptRejectsWrongCount() {
        let json = """
        ["only one", "only two"]
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(AIBriefScript.self, from: json)) { error in
            guard case DecodingError.dataCorrupted(let ctx) = error else {
                XCTFail("Expected dataCorrupted, got \(error)")
                return
            }
            XCTAssertTrue(ctx.debugDescription.contains("exactly 3"))
        }
    }

    func testBriefScriptDecodes() throws {
        let json = """
        ["Opening line", "Question one? Question two?", "Closing standard"]
        """.data(using: .utf8)!

        let script = try JSONDecoder().decode(AIBriefScript.self, from: json)
        XCTAssertEqual(script.opening, "Opening line")
        XCTAssertEqual(script.keyQuestions, "Question one? Question two?")
        XCTAssertEqual(script.closing, "Closing standard")
    }

    // MARK: - Individual model decoding

    func testAIFatalExposureDecodes() throws {
        let json = """
        {"exposure": "E", "why_it_kills": "W", "critical_controls": ["C1", "C2"]}
        """.data(using: .utf8)!

        let model = try JSONDecoder().decode(AIFatalExposure.self, from: json)
        XCTAssertEqual(model.exposure, "E")
        XCTAssertEqual(model.whyItKills, "W")
        XCTAssertEqual(model.criticalControls, ["C1", "C2"])
    }

    func testAIPrimaryEnergySourceDecodes() throws {
        let json = """
        {"type": "Electrical", "examples": ["E1"], "controls": ["C1"]}
        """.data(using: .utf8)!

        let model = try JSONDecoder().decode(AIPrimaryEnergySource.self, from: json)
        XCTAssertEqual(model.type, "Electrical")
        XCTAssertEqual(model.examples, ["E1"])
        XCTAssertEqual(model.controls, ["C1"])
    }

    func testAIHazardDecodes() throws {
        let json = """
        {
          "hazard": "H", "line_of_fire": false, "likelihood": "Low",
          "severity": "Med", "controls": ["C"], "verification": ["V"]
        }
        """.data(using: .utf8)!

        let model = try JSONDecoder().decode(AIHazard.self, from: json)
        XCTAssertEqual(model.hazard, "H")
        XCTAssertFalse(model.lineOfFire)
        XCTAssertEqual(model.likelihood, "Low")
        XCTAssertEqual(model.severity, "Med")
    }

    func testAIHumanPerformanceDecodes() throws {
        let json = """
        {
          "error_precursors": ["EP"],
          "likely_traps": ["LT"],
          "countermeasures": ["CM"],
          "stop_work_triggers": ["SW"]
        }
        """.data(using: .utf8)!

        let model = try JSONDecoder().decode(AIHumanPerformance.self, from: json)
        XCTAssertEqual(model.errorPrecursors, ["EP"])
        XCTAssertEqual(model.likelyTraps, ["LT"])
        XCTAssertEqual(model.countermeasures, ["CM"])
        XCTAssertEqual(model.stopWorkTriggers, ["SW"])
    }
}
