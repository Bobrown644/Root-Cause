#if canImport(SwiftUI)
import SwiftUI

struct WhyChainProgressView: View {
    let currentDepth: Int
    let maxDepth: Int = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Progress")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(currentDepth) / \(maxDepth) Whys")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: currentDepth)
                }
            }
            .frame(height: 8)
        }
    }

    private var progress: Double {
        min(Double(currentDepth) / Double(maxDepth), 1.0)
    }

    private var progressColor: Color {
        switch currentDepth {
        case 0...1: return .red
        case 2...3: return .orange
        case 4: return .yellow
        default: return .green
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        WhyChainProgressView(currentDepth: 0)
        WhyChainProgressView(currentDepth: 2)
        WhyChainProgressView(currentDepth: 5)
    }
    .padding()
}
#endif
