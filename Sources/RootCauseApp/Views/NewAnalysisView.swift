#if canImport(SwiftUI)
import SwiftUI
import RootCauseCore

struct NewAnalysisView: View {
    @StateObject private var viewModel = NewAnalysisViewModel()
    @Environment(\.dismiss) private var dismiss
    let onCreate: (Analysis) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Problem Statement") {
                    TextField(
                        "What went wrong?",
                        text: $viewModel.problemStatement,
                        axis: .vertical
                    )
                    .lineLimit(2...5)
                }

                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(AnalysisCategory.allCases) { category in
                            Label(category.displayName, systemImage: category.iconName)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    TextField(
                        "Because... (optional)",
                        text: $viewModel.firstWhyAnswer,
                        axis: .vertical
                    )
                    .lineLimit(1...4)
                } header: {
                    Text("First Why")
                } footer: {
                    Text("Optionally provide the first answer in the 5 Whys chain.")
                }

                Section {
                    Button {
                        let analysis = viewModel.createAnalysis()
                        onCreate(analysis)
                        dismiss()
                    } label: {
                        Text("Create Analysis")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .navigationTitle("New Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NewAnalysisView(onCreate: { _ in })
}
#endif
