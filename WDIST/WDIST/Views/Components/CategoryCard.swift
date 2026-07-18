import SwiftUI

struct CategoryCard: View {
    let category: ScreenshotCategory
    let count: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: category.symbolName).font(.title2).foregroundStyle(.tint)
            Spacer(minLength: 4)
            Text(category.rawValue).font(.subheadline.weight(.semibold)).foregroundStyle(.primary).lineLimit(1)
            Text("\(count) \(count == 1 ? "memory" : "memories")").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(.quaternary, lineWidth: 1) }
    }
}
