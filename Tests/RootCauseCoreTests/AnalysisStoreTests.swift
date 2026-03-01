import XCTest
@testable import RootCauseCore

final class AnalysisStoreTests: XCTestCase {
    var store: AnalysisStore!
    var tempFileURL: URL!

    override func setUp() {
        super.setUp()
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        tempFileURL = tempDir.appendingPathComponent("test_analyses.json")
        store = AnalysisStore(fileURL: tempFileURL)
    }

    override func tearDown() {
        let dir = tempFileURL.deletingLastPathComponent()
        try? FileManager.default.removeItem(at: dir)
        super.tearDown()
    }

    func testFetchEmptyReturnsEmptyArray() throws {
        let results = try store.fetchAll()
        XCTAssertTrue(results.isEmpty)
    }

    func testSaveAndFetch() throws {
        let analysis = Analysis(title: "Test problem", category: .engineering)
        try store.save(analysis)

        let results = try store.fetchAll()
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Test problem")
        XCTAssertEqual(results.first?.category, .engineering)
    }

    func testSaveMultiple() throws {
        let a1 = Analysis(title: "Problem 1", category: .process)
        let a2 = Analysis(title: "Problem 2", category: .people)
        try store.save(a1)
        try store.save(a2)

        let results = try store.fetchAll()
        XCTAssertEqual(results.count, 2)
    }

    func testDelete() throws {
        let analysis = Analysis(title: "To delete", category: .tooling)
        try store.save(analysis)
        XCTAssertEqual(try store.fetchAll().count, 1)

        try store.delete(id: analysis.id)
        XCTAssertEqual(try store.fetchAll().count, 0)
    }

    func testUpdate() throws {
        var analysis = Analysis(title: "Original", category: .communication)
        try store.save(analysis)

        analysis.addWhy(answer: "First why answer")
        try store.update(analysis)

        let results = try store.fetchAll()
        XCTAssertEqual(results.first?.whyEntries.count, 1)
        XCTAssertEqual(results.first?.whyEntries.first?.answer, "First why answer")
    }

    func testUpdateNonexistentThrows() throws {
        let analysis = Analysis(title: "Ghost", category: .other)
        XCTAssertThrowsError(try store.update(analysis)) { error in
            XCTAssertTrue(error is AnalysisStore.StoreError)
        }
    }

    func testCompleteRoundTrip() throws {
        var analysis = Analysis(title: "Full test", category: .engineering)
        analysis.addWhy(answer: "Why 1")
        analysis.addWhy(answer: "Why 2")
        analysis.complete(with: "The real root cause")
        try store.save(analysis)

        let loaded = try store.fetchAll().first!
        XCTAssertEqual(loaded.status, .completed)
        XCTAssertEqual(loaded.rootCause, "The real root cause")
        XCTAssertEqual(loaded.whyEntries.count, 2)
    }

    func testDateFormatter() {
        let formatted = store.dateFormatter.string(from: Date())
        XCTAssertFalse(formatted.isEmpty)
    }
}
