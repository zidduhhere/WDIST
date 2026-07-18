import SwiftUI

struct SearchFilterChip: View {
    let title: String
    var symbol: String?
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) { if let symbol { Image(systemName: symbol) }; Text(title) }
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12).padding(.vertical, 9)
                .background(isSelected ? Color.accentColor : Color.primary.opacity(0.08), in: Capsule())
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }.buttonStyle(.plain)
    }
}
