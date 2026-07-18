import SwiftUI

struct ScreenshotCard: View {
    let item: ScreenshotItem
    var matchTerms: [String] = []
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                ThumbnailView(item: item).frame(width: 96, height: 112)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 7) { CategoryBadge(category: item.category); Text(item.capturedAt.memoryDisplay).font(.caption).foregroundStyle(.secondary) }
                    Text(item.summary).font(.subheadline.weight(.semibold)).foregroundStyle(.primary).lineLimit(3).multilineTextAlignment(.leading)
                    if !matchTerms.isEmpty { Text(matchTerms.prefix(3).map { "#\($0)" }.joined(separator: "  ")).font(.caption).foregroundStyle(.tint).lineLimit(1) }
                    else { TagWrap(tags: Array(item.tags.prefix(3))) }
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(.quaternary, lineWidth: 1) }
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("\(item.category.rawValue), \(item.summary)")
    }
}
