#if canImport(SwiftUI)
import SwiftUI
import RootCauseCore

struct AnalysisListView: View {
    @StateObject private var viewModel = AnalysisListViewModel()
    @State private var showNewAnalysis = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.analyses.isEmpty {
                    emptyStateView
                } else {
                    analysisList
                }
            }
            .navigationTitle("Root Cause")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewAnalysis = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search analyses...")
            .sheet(isPresented: $showNewAnalysis) {
                NewAnalysisView { analysis in
                    viewModel.addAnalysis(analysis)
                }
            }
            .onAppear {
                viewModel.loadAnalyses()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Analyses", systemImage: "magnifyingglass.circle")
        } description: {
            Text("Start your first root cause analysis by tapping the + button.")
        } actions: {
            Button("New Analysis") {
                showNewAnalysis = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var analysisList: some View {
        VStack(spacing: 0) {
            statsHeader
            filterPicker
            List {
                ForEach(viewModel.filteredAnalyses) { analysis in
                    NavigationLink(value: analysis.id) {
                        AnalysisRowView(analysis: analysis)
                    }
                }
                .onDelete(perform: viewModel.deleteAnalysis)
            }
            .listStyle(.insetGrouped)
            .navigationDestination(for: UUID.self) { id in
                if let analysis = viewModel.analyses.first(where: { $0.id == id }) {
                    AnalysisDetailView(
                        analysis: analysis,
                        onUpdate: { viewModel.loadAnalyses() }
                    )
                }
            }
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total",
                value: "\(viewModel.analyses.count)",
                icon: "list.bullet",
                color: .blue
            )
            StatCard(
                title: "Active",
                value: "\(viewModel.inProgressCount)",
                icon: "clock",
                color: .orange
            )
            StatCard(
                title: "Done",
                value: "\(viewModel.completedCount)",
                icon: "checkmark",
                color: .green
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.statusFilterOptions, id: \.0) { option in
                    FilterChip(
                        title: option.0,
                        isSelected: viewModel.selectedStatus == option.1,
                        action: { viewModel.selectedStatus = option.1 }
                    )
                }
                Divider().frame(height: 24)
                ForEach(AnalysisCategory.allCases) { category in
                    FilterChip(
                        title: category.displayName,
                        isSelected: viewModel.selectedCategory == category,
                        action: {
                            viewModel.selectedCategory =
                                viewModel.selectedCategory == category ? nil : category
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 4)
    }
}

struct AnalysisRowView: View {
    let analysis: Analysis

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(analysis.title)
                .font(.headline)
                .lineLimit(2)
            HStack(spacing: 8) {
                CategoryBadge(category: analysis.category)
                StatusBadge(status: analysis.status)
                Spacer()
                Text("\(analysis.currentDepth) whys")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AnalysisListView()
}
#endif
