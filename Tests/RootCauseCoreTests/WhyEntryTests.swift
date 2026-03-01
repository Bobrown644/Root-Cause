import XCTest
@testable import RootCauseCore

final class WhyEntryTests: XCTestCase {

    func testInit() {
        let entry = WhyEntry(depth: 3, answer: "No monitoring in place")
        XCTAssertEqual(entry.depth, 3)
        XCTAssertEqual(entry.answer, "No monitoring in place")
    }

    func testQuestion() {
        let entry1 = WhyEntry(depth: 1, answer: "")
        XCTAssertEqual(entry1.question, "Why #1?")

        let entry5 = WhyEntry(depth: 5, answer: "")
        XCTAssertEqual(entry5.question, "Why #5?")
    }

    func testDefaultEmptyAnswer() {
        let entry = WhyEntry(depth: 1)
        XCTAssertEqual(entry.answer, "")
    }

    func testCodable() throws {
        let entry = WhyEntry(depth: 2, answer: "Test answer")
        let data = try JSONEncoder.appEncoder.encode(entry)
        let decoded = try JSONDecoder.appDecoder.decode(WhyEntry.self, from: data)
        XCTAssertEqual(decoded.id, entry.id)
        XCTAssertEqual(decoded.depth, entry.depth)
        XCTAssertEqual(decoded.answer, entry.answer)
    }

    func testEquatable() {
        let id = UUID()
        let date = Date()
        let a = WhyEntry(id: id, depth: 1, answer: "A", createdAt: date)
        let b = WhyEntry(id: id, depth: 1, answer: "A", createdAt: date)
        XCTAssertEqual(a, b)
    }
}
