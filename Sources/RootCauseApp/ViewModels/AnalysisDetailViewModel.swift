#if canImport(SwiftUI) && canImport(Combine)
import SwiftUI
import Combine
import RootCauseCore

final class AnalysisDetailViewModel: ObservableObject {
    @Published var analysis: Analysis
    @Published var newWhyAnswer: String = ""
    @Published var rootCauseText: String = ""
    @Published var showCompleteSheet: Bool = false
    @Published var errorMessage: String?

    private let store: AnalysisStoring

    init(analysis: Analysis, store: AnalysisStoring = AnalysisStore()) {
        self.analysis = analysis
        self.store = store
        self.rootCauseText = analysis.rootCause ?? ""
    }

    var canAddWhy: Bool {
        !analysis.isComplete && !newWhyAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canComplete: Bool {
        !analysis.isComplete
            && analysis.currentDepth >= 1
            && !rootCauseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var progressPercentage: Double {
        min(Double(analysis.currentDepth) / 5.0, 1.0)
    }

    func addWhy() {
        let trimmed = newWhyAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        analysis.addWhy(answer: trimmed)
        newWhyAnswer = ""
        save()
    }

    func completeAnalysis() {
        let trimmed = rootCauseText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        analysis.complete(with: trimmed)
        showCompleteSheet = false
        save()
    }

    func reopenAnalysis() {
        analysis.reopen()
        rootCauseText = ""
        save()
    }

    private func save() {
        do {
            try store.update(analysis)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
#endif
