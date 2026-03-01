#if canImport(SwiftUI)
import SwiftUI
import RootCauseCore

struct AnalysisDetailView: View {
    @StateObject private var viewModel: AnalysisDetailViewModel
    private let onUpdate: () -> Void

    init(analysis: Analysis, onUpdate: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: AnalysisDetailViewModel(analysis: analysis))
        self.onUpdate = onUpdate
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                progressSection
                whyChainSection
                if viewModel.analysis.isComplete {
                    rootCauseSection
                } else {
                    addWhySection
                    completeSection
                }
            }
            .padding()
        }
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if viewModel.analysis.isComplete {
                    Button("Reopen") {
                        viewModel.reopenAnalysis()
                        onUpdate()
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showCompleteSheet) {
            completeSheet
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Problem Statement")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1)
            Text(viewModel.analysis.title)
                .font(.title3)
                .fontWeight(.semibold)
            HStack(spacing: 8) {
                CategoryBadge(category: viewModel.analysis.category)
                StatusBadge(status: viewModel.analysis.status)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var progressSection: some View {
        WhyChainProgressView(currentDepth: viewModel.analysis.currentDepth)
    }

    private var whyChainSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.analysis.whyEntries.isEmpty {
                Text("No whys yet. Start asking why!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            } else {
                ForEach(Array(viewModel.analysis.whyEntries.enumerated()), id: \.element.id) { index, entry in
                    WhyEntryRow(
                        entry: entry,
                        isLast: index == viewModel.analysis.whyEntries.count - 1
                    )
                }
            }
        }
    }

    private var addWhySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Why #\(viewModel.analysis.currentDepth + 1)?")
                .font(.headline)
            HStack {
                TextField("Because...", text: $viewModel.newWhyAnswer, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                Button {
                    viewModel.addWhy()
                    onUpdate()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .imageScale(.large)
                }
                .disabled(!viewModel.canAddWhy)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var completeSection: some View {
        Button {
            viewModel.showCompleteSheet = true
        } label: {
            Label("Mark Root Cause Found", systemImage: "checkmark.seal")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
        .disabled(viewModel.analysis.whyEntries.isEmpty)
    }

    private var rootCauseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Root Cause Identified", systemImage: "checkmark.seal.fill")
                .font(.headline)
                .foregroundStyle(.green)
            Text(viewModel.analysis.rootCause ?? "")
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var completeSheet: some View {
        NavigationStack {
            Form {
                Section("Root Cause Summary") {
                    TextField("Describe the root cause...", text: $viewModel.rootCauseText, axis: .vertical)
                        .lineLimit(3...8)
                }
                Section {
                    Button("Confirm Root Cause") {
                        viewModel.completeAnalysis()
                        onUpdate()
                    }
                    .disabled(!viewModel.canComplete)
                }
            }
            .navigationTitle("Complete Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showCompleteSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        AnalysisDetailView(
            analysis: Analysis(
                title: "Production server crashed at 3 AM",
                category: .engineering,
                whyEntries: [
                    WhyEntry(depth: 1, answer: "The server ran out of memory."),
                    WhyEntry(depth: 2, answer: "A memory leak in the caching layer."),
                ]
            ),
            onUpdate: {}
        )
    }
}
#endif
