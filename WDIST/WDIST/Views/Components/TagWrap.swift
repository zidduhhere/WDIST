import SwiftUI

struct TagWrap: View {
    let tags: [Tag]
    var body: some View {
        Text(tags.prefix(3).map { "#\($0.value)" }.joined(separator: "  "))
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }
}
