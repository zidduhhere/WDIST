import SwiftUI

struct SearchPromptView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "sparkles").font(.largeTitle).foregroundStyle(.tint)
            Text("Search like you remember").font(.title2.weight(.bold))
            Text("Try “the internship from LinkedIn”, “a recipe with mushrooms”, or “the hackathon QR code”.").foregroundStyle(.secondary)
        }
        .padding(22).frame(maxWidth: .infinity, alignment: .leading)
        .background(.tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
