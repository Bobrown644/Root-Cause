#if canImport(SwiftUI) && canImport(Combine)
import SwiftUI
import Combine
import RootCauseCore

final class AnalysisListViewModel: ObservableObject {
    @Published var analyses: [Analysis] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: AnalysisCategory?
    @Published var selectedStatus: AnalysisStatus?
    @Published var errorMessage: String?

    private let store: AnalysisStoring

    lazy var statusFilterOptions: [(String, AnalysisStatus?)] = {
        var options: [(String, AnalysisStatus?)] = [("All", nil)]
        options.append(contentsOf: AnalysisStatus.allCases.map { status in
            let name = status == .inProgress ? "In Progress" : "Completed"
            return (name, Optional(status))
        })
        return options
    }()

    init(store: AnalysisStoring = AnalysisStore()) {
        self.store = store
    }

    var filteredAnalyses: [Analysis] {
        analyses.filter { analysis in
            let matchesSearch = searchText.isEmpty
                || analysis.title.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil
                || analysis.category == selectedCategory
            let matchesStatus = selectedStatus == nil
                || analysis.status == selectedStatus
            return matchesSearch && matchesCategory && matchesStatus
        }
    }

    var inProgressCount: Int {
        analyses.filter { $0.status == .inProgress }.count
    }

    var completedCount: Int {
        analyses.filter { $0.status == .completed }.count
    }

    func loadAnalyses() {
        do {
            analyses = try store.fetchAll().sorted { $0.updatedAt > $1.updatedAt }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteAnalysis(at offsets: IndexSet) {
        let toDelete = offsets.map { filteredAnalyses[$0] }
        for analysis in toDelete {
            do {
                try store.delete(id: analysis.id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        loadAnalyses()
    }

    func addAnalysis(_ analysis: Analysis) {
        do {
            try store.save(analysis)
            loadAnalyses()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
#endif
