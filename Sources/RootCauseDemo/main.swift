import Foundation
import RootCauseCore

print("=== Root-Cause: 5 Whys Analysis Demo ===\n")

let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("RootCauseDemo")
try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
let fileURL = tempDir.appendingPathComponent("demo_analyses.json")
let store = AnalysisStore(fileURL: fileURL)

var analysis = Analysis(
    title: "Production API response time increased by 300%",
    category: .engineering
)
print("Created analysis: \"\(analysis.title)\"")
print("Category: \(analysis.category.displayName)")
print("Status: \(analysis.status == .inProgress ? "In Progress" : "Completed")")
print()

let whyAnswers = [
    "Database queries are taking 10x longer than normal.",
    "The users table is doing a full table scan on every request.",
    "The index on the email column was dropped during last migration.",
    "The migration script had a bug that dropped all indexes.",
    "There were no integration tests covering index preservation.",
]

for answer in whyAnswers {
    analysis.addWhy(answer: answer)
    let entry = analysis.whyEntries.last!
    print("  \(entry.question) \(entry.answer)")
}

print()
print("Depth: \(analysis.currentDepth) / 5 whys")
print()

let rootCause = "Missing integration tests for database migrations allowed an index-dropping bug to reach production."
analysis.complete(with: rootCause)

print("Root Cause Found!")
print("  \(analysis.rootCause!)")
print("Status: \(analysis.status == .completed ? "Completed" : "In Progress")")
print()

try store.save(analysis)
let loaded = try store.fetchAll()
print("Persisted \(loaded.count) analysis to store.")
print("Verified round-trip: loaded title = \"\(loaded.first!.title)\"")
print("Verified round-trip: loaded whys = \(loaded.first!.whyEntries.count)")
print("Verified round-trip: loaded root cause = \"\(loaded.first!.rootCause ?? "nil")\"")
print()

var analysis2 = Analysis(title: "Customer onboarding emails not sending", category: .communication)
analysis2.addWhy(answer: "The email service queue is backed up.")
analysis2.addWhy(answer: "Worker processes crashed overnight.")
try store.save(analysis2)

let allAnalyses = try store.fetchAll()
print("Total analyses in store: \(allAnalyses.count)")
for a in allAnalyses {
    let status = a.status == .completed ? "COMPLETED" : "IN PROGRESS"
    print("  [\(status)] \(a.title) (\(a.currentDepth) whys)")
}

try? FileManager.default.removeItem(at: tempDir)

print()
print("=== Demo Complete ===")
