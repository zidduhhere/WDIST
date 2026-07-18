import SwiftUI
import ImageIO

struct ScreenshotPreview: View {
    let item: ScreenshotItem
    var body: some View {
        Group {
            if let data = item.thumbnailData, let image = PreviewDecoder.image(from: data) {
                Image(decorative: image, scale: 1, orientation: .up).resizable().scaledToFit().padding(12)
            } else {
                VStack(spacing: 14) { Image(systemName: item.category.symbolName).font(.system(size: 48)); Text(item.category.rawValue).font(.headline) }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private enum PreviewDecoder {
    static func image(from data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
}
