import XCTest
@testable import RootCauseCore

final class AnalysisTests: XCTestCase {

    func testInitWithDefaults() {
        let analysis = Analysis(title: "Server crashed", category: .engineering)
        XCTAssertEqual(analysis.title, "Server crashed")
        XCTAssertEqual(analysis.category, .engineering)
        XCTAssertEqual(analysis.status, .inProgress)
        XCTAssertTrue(analysis.whyEntries.isEmpty)
        XCTAssertNil(analysis.rootCause)
        XCTAssertEqual(analysis.currentDepth, 0)
        XCTAssertFalse(analysis.isComplete)
    }

    func testAddWhy() {
        var analysis = Analysis(title: "Bug in prod", category: .engineering)
        analysis.addWhy(answer: "Missing null check")
        XCTAssertEqual(analysis.currentDepth, 1)
        XCTAssertEqual(analysis.whyEntries.first?.answer, "Missing null check")
        XCTAssertEqual(analysis.whyEntries.first?.depth, 1)
        XCTAssertEqual(analysis.whyEntries.first?.question, "Why #1?")
    }

    func testAddMultipleWhys() {
        var analysis = Analysis(title: "Outage", category: .process)
        analysis.addWhy(answer: "First")
        analysis.addWhy(answer: "Second")
        analysis.addWhy(answer: "Third")
        XCTAssertEqual(analysis.currentDepth, 3)
        XCTAssertEqual(analysis.whyEntries[0].depth, 1)
        XCTAssertEqual(analysis.whyEntries[1].depth, 2)
        XCTAssertEqual(analysis.whyEntries[2].depth, 3)
    }

    func testComplete() {
        var analysis = Analysis(title: "Slow response", category: .tooling)
        analysis.addWhy(answer: "Database query timeout")
        analysis.complete(with: "Missing index on users table")
        XCTAssertTrue(analysis.isComplete)
        XCTAssertEqual(analysis.status, .completed)
        XCTAssertEqual(analysis.rootCause, "Missing index on users table")
    }

    func testReopen() {
        var analysis = Analysis(title: "Test", category: .other)
        analysis.addWhy(answer: "Something")
        analysis.complete(with: "Root cause found")
        XCTAssertTrue(analysis.isComplete)

        analysis.reopen()
        XCTAssertFalse(analysis.isComplete)
        XCTAssertEqual(analysis.status, .inProgress)
        XCTAssertNil(analysis.rootCause)
    }

    func testUpdatedAtChangesOnAddWhy() {
        let oldDate = Date(timeIntervalSince1970: 1000)
        var analysis = Analysis(
            title: "Test",
            category: .people,
            updatedAt: oldDate
        )
        analysis.addWhy(answer: "Answer")
        XCTAssertGreaterThan(analysis.updatedAt, oldDate)
    }

    func testUpdatedAtChangesOnComplete() {
        let oldDate = Date(timeIntervalSince1970: 1000)
        var analysis = Analysis(
            title: "Test",
            category: .communication,
            whyEntries: [WhyEntry(depth: 1, answer: "Because")],
            updatedAt: oldDate
        )
        analysis.complete(with: "Root")
        XCTAssertGreaterThan(analysis.updatedAt, oldDate)
    }

    func testCodable() throws {
        var analysis = Analysis(title: "Encoding test", category: .process)
        analysis.addWhy(answer: "Test answer")
        analysis.complete(with: "Test root cause")

        let data = try JSONEncoder.appEncoder.encode(analysis)
        let decoded = try JSONDecoder.appDecoder.decode(Analysis.self, from: data)

        XCTAssertEqual(decoded.id, analysis.id)
        XCTAssertEqual(decoded.title, analysis.title)
        XCTAssertEqual(decoded.category, analysis.category)
        XCTAssertEqual(decoded.status, analysis.status)
        XCTAssertEqual(decoded.whyEntries.count, analysis.whyEntries.count)
        XCTAssertEqual(decoded.rootCause, analysis.rootCause)
    }

    func testEquatable() {
        let id = UUID()
        let date = Date()
        let a = Analysis(id: id, title: "A", category: .engineering, createdAt: date, updatedAt: date)
        let b = Analysis(id: id, title: "A", category: .engineering, createdAt: date, updatedAt: date)
        XCTAssertEqual(a, b)
    }
}
