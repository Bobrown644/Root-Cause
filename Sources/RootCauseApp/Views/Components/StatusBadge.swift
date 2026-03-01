#if canImport(SwiftUI)
import SwiftUI
import RootCauseCore

struct StatusBadge: View {
    let status: AnalysisStatus

    private var color: Color {
        switch status {
        case .inProgress: return .orange
        case .completed: return .green
        }
    }

    private var label: String {
        switch status {
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }

    private var icon: String {
        switch status {
        case .inProgress: return "clock.arrow.circlepath"
        case .completed: return "checkmark.circle.fill"
        }
    }

    var body: some View {
        Label(label, systemImage: icon)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 8) {
        StatusBadge(status: .inProgress)
        StatusBadge(status: .completed)
    }
    .padding()
}
#endif
