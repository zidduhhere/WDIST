import SwiftUI

struct CategoryBadge: View {
    let category: ScreenshotCategory
    var body: some View {
        Label(category.rawValue, systemImage: category.symbolName)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.tint)
            .lineLimit(1)
            .padding(.horizontal, 8).padding(.vertical, 5)
            .background(.tint.opacity(0.10), in: Capsule())
    }
}
