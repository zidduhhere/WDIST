import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 0.985 : 1).animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}
