import Foundation

public final class MockAIClient: AIClient, @unchecked Sendable {
    public private(set) var lastSystemPrompt: String?
    public private(set) var lastUserPrompt: String?
    public private(set) var callCount: Int = 0

    private let fixtureJSON: String

    public init(fixtureJSON: String? = nil) {
        self.fixtureJSON = fixtureJSON ?? Self.defaultFixture
    }

    public func complete(systemPrompt: String, userPrompt: String) async throws -> String {
        lastSystemPrompt = systemPrompt
        lastUserPrompt = userPrompt
        callCount += 1
        return fixtureJSON
    }

    // MARK: - Default fixture matching the LineReady schema

    public static let defaultFixture: String = """
    {
      "job_summary": {
        "work_type": "Line Stringing",
        "voltage_level": "345kV",
        "environment": ["Rural", "Adjacent Energized"],
        "crew_size": 8,
        "equipment": ["Tensioner", "Puller", "Bucket Truck"],
        "time_pressure": "Moderate",
        "fatigue_risk": false,
        "new_crew_member": true
      },
      "fatal3": [
        {
          "exposure": "Electrocution from contact with adjacent energized 345kV circuit",
          "why_it_kills": "Phase-to-ground fault through the body at 345kV is unsurvivable",
          "critical_controls": [
            "MAD maintained for all equipment and personnel",
            "Dedicated observer assigned to monitor MAD encroachment",
            "Grounds installed and tested at work location"
          ]
        },
        {
          "exposure": "Struck by conductor or rigging under tension",
          "why_it_kills": "Conductor whip or rigging failure releases stored energy at lethal velocity",
          "critical_controls": [
            "All personnel clear of line-of-fire during tensioning operations",
            "Rigging inspected and rated for load before each pull",
            "Pulling tensions monitored against sag charts continuously"
          ]
        },
        {
          "exposure": "Falls from transmission structures during conductor attachment",
          "why_it_kills": "Falls from transmission structure heights exceed survivable limits",
          "critical_controls": [
            "100% tie-off with dual-lanyard verified at every transition point",
            "Climbing inspection completed before ascent",
            "Rescue plan briefed and equipment staged at structure base"
          ]
        }
      ],
      "primary_energy_sources": [
        {
          "type": "Electrical",
          "examples": ["345kV adjacent energized circuit", "Induced voltage on de-energized conductor"],
          "controls": [
            "Grounds installed both sides of work zone and tested",
            "EPZ established and bonded at each ground set",
            "MAD maintained with dedicated observer posted"
          ]
        },
        {
          "type": "Mechanical",
          "examples": ["Stored energy in tensioner", "Conductor under pulling tension"],
          "controls": [
            "Line-of-fire zones established and marked at each pull point",
            "Tensioner brakes verified functional before crew approaches",
            "Dead-end anchors inspected for rated load capacity"
          ]
        },
        {
          "type": "Gravitational",
          "examples": ["Working at height on structures", "Suspended conductor and hardware"],
          "controls": [
            "100% tie-off enforced above 4 ft",
            "Tag lines on all suspended loads",
            "Drop zone established and barricaded below work area"
          ]
        }
      ],
      "top_hazards": [
        {
          "hazard": "Induced voltage on conductor from adjacent 345kV circuit",
          "line_of_fire": true,
          "likelihood": "High",
          "severity": "Fatal",
          "controls": [
            "Equipotential zone established at each ground point",
            "Grounds installed and tested with meter before touching conductor",
            "Bonding jumpers installed on all conductive equipment in EPZ"
          ],
          "verification": [
            "Foreman verifies ground readings before crew contacts conductor",
            "Peer check: second QEP confirms EPZ bonding continuity"
          ]
        },
        {
          "hazard": "MAD encroachment by tensioner boom or conductor sag",
          "line_of_fire": true,
          "likelihood": "Med",
          "severity": "Fatal",
          "controls": [
            "Dedicated observer posted with sole duty to monitor MAD",
            "Physical MAD markers set at structure work locations",
            "Tensioner operator briefed on boom swing limits"
          ],
          "verification": [
            "Observer confirms MAD clearance before each pull sequence",
            "Foreman spot-checks MAD marker positions at each structure"
          ]
        },
        {
          "hazard": "Conductor whip during tensioning or clipping operations",
          "line_of_fire": true,
          "likelihood": "Med",
          "severity": "Fatal",
          "controls": [
            "All crew clear of line-of-fire before any tension changes",
            "Running grounds installed during stringing operations",
            "Radio communication confirmed between puller and tensioner"
          ],
          "verification": [
            "Foreman confirms all hands clear before tension command",
            "Radio check completed between puller and tensioner before pull"
          ]
        },
        {
          "hazard": "Rigging failure at pulling or dead-end anchor point",
          "line_of_fire": true,
          "likelihood": "Low",
          "severity": "Fatal",
          "controls": [
            "Rigging inspected and rated for 2x expected load",
            "Snatch blocks and shackles matched to manufacturer load chart",
            "Line-of-fire zone enforced at every pulling and anchor point"
          ],
          "verification": [
            "Rigging foreman signs off inspection before tensioning begins",
            "Peer check on shackle pin engagement and cotter placement"
          ]
        },
        {
          "hazard": "Fall during structure climbing for sock or traveler install",
          "line_of_fire": false,
          "likelihood": "Med",
          "severity": "Fatal",
          "controls": [
            "100% tie-off with dual-lanyard at all times above 4 ft",
            "Pre-climb body harness and structure inspection completed",
            "Rescue plan briefed with equipment positioned at base"
          ],
          "verification": [
            "Ground crew visually confirms tie-off at each transition point",
            "Climbing gear inspection logged before each ascent"
          ]
        }
      ],
      "human_performance": {
        "error_precursors": [
          "New crew member unfamiliar with stringing sequence and crew signals",
          "Production pressure to complete pull before weather window closes",
          "Multiple simultaneous tasks across multiple structures"
        ],
        "likely_traps": [
          "Normalization of deviance: skipping EPZ bonding check on repeat pulls",
          "Confirmation bias: assuming grounds are good without re-testing",
          "Rushing past point-of-no-return on tension without final crew check"
        ],
        "countermeasures": [
          "Pair new crew member with experienced hand for every assigned task",
          "Mandatory time-out and 2-minute drill before each pull sequence begins",
          "Independent verification of grounds and EPZ by second QEP on site"
        ],
        "stop_work_triggers": [
          "Ground test readings outside acceptable range after installation",
          "Any crew member observed inside line-of-fire during tensioning",
          "MAD encroachment detected by dedicated observer at any structure",
          "Communication failure between puller and tensioner operators"
        ]
      },
      "brief_script": [
        "We are pulling wire next to a hot 345kV line — induction will kill you if the EPZ fails.",
        "Who is our dedicated MAD observer today? Can each person point to their nearest EPZ exit?",
        "Nobody touches conductor until grounds are tested and I give the word — stop-work is expected."
      ]
    }
    """
}
