#if canImport(SwiftUI)
import SwiftUI
import RootCauseCore

struct CategoryBadge: View {
    let category: AnalysisCategory

    private var color: Color {
        switch category {
        case .engineering: return .blue
        case .process: return .purple
        case .people: return .orange
        case .tooling: return .green
        case .communication: return .teal
        case .other: return .gray
        }
    }

    var body: some View {
        Label(category.displayName, systemImage: category.iconName)
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
        ForEach(AnalysisCategory.allCases) { category in
            CategoryBadge(category: category)
        }
    }
    .padding()
}
#endif
