#if canImport(SwiftUI) && canImport(Combine)
import SwiftUI
import Combine
import RootCauseCore

final class NewAnalysisViewModel: ObservableObject {
    @Published var problemStatement: String = ""
    @Published var selectedCategory: AnalysisCategory = .engineering
    @Published var firstWhyAnswer: String = ""

    var isValid: Bool {
        !problemStatement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func createAnalysis() -> Analysis {
        var analysis = Analysis(
            title: problemStatement.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory
        )
        let trimmedWhy = firstWhyAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedWhy.isEmpty {
            analysis.addWhy(answer: trimmedWhy)
        }
        return analysis
    }

    func reset() {
        problemStatement = ""
        selectedCategory = .engineering
        firstWhyAnswer = ""
    }
}
#endif
