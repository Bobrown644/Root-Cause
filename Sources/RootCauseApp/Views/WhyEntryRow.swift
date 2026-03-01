#if canImport(SwiftUI)
import SwiftUI
import RootCauseCore

struct WhyEntryRow: View {
    let entry: WhyEntry
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(depthColor)
                        .frame(width: 36, height: 36)
                    Text("\(entry.depth)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                if !isLast {
                    Rectangle()
                        .fill(depthColor.opacity(0.3))
                        .frame(width: 2)
                        .frame(minHeight: 20)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.question)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Text(entry.answer)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, isLast ? 0 : 12)

            Spacer()
        }
    }

    private var depthColor: Color {
        switch entry.depth {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .mint
        default: return .green
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        WhyEntryRow(
            entry: WhyEntry(depth: 1, answer: "The server crashed due to high memory usage."),
            isLast: false
        )
        WhyEntryRow(
            entry: WhyEntry(depth: 2, answer: "A memory leak in the caching layer."),
            isLast: true
        )
    }
    .padding()
}
#endif
