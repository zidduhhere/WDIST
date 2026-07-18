import SwiftUI

struct EmptyIndexView: View {
    let action: () -> Void
    var body: some View {
        ContentUnavailableView {
            Label("Your memory shelf is ready", systemImage: "photo.stack")
        } description: {
            Text("Allow Photos access to let this app find and understand your screenshots.")
        } actions: {
            Button("Try again", action: action).buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 32)
    }
}
