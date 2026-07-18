import SwiftUI

struct SectionTitle: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.title2.weight(.bold))
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
        }
    }
}
