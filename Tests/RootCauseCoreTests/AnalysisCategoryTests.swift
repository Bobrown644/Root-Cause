import XCTest
@testable import RootCauseCore

final class AnalysisCategoryTests: XCTestCase {

    func testAllCasesCount() {
        XCTAssertEqual(AnalysisCategory.allCases.count, 6)
    }

    func testDisplayNames() {
        XCTAssertEqual(AnalysisCategory.engineering.displayName, "Engineering")
        XCTAssertEqual(AnalysisCategory.process.displayName, "Process")
        XCTAssertEqual(AnalysisCategory.people.displayName, "People")
        XCTAssertEqual(AnalysisCategory.tooling.displayName, "Tooling")
        XCTAssertEqual(AnalysisCategory.communication.displayName, "Communication")
        XCTAssertEqual(AnalysisCategory.other.displayName, "Other")
    }

    func testIconNames() {
        for category in AnalysisCategory.allCases {
            XCTAssertFalse(category.iconName.isEmpty, "\(category) should have an icon name")
        }
    }

    func testIdentifiable() {
        for category in AnalysisCategory.allCases {
            XCTAssertEqual(category.id, category.rawValue)
        }
    }

    func testCodable() throws {
        for category in AnalysisCategory.allCases {
            let data = try JSONEncoder().encode(category)
            let decoded = try JSONDecoder().decode(AnalysisCategory.self, from: data)
            XCTAssertEqual(decoded, category)
        }
    }
}
