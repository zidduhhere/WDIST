import SwiftUI
import ImageIO

struct ThumbnailView: View {
    let item: ScreenshotItem

    var body: some View {
        Group {
            if let data = item.thumbnailData, let image = ThumbnailDecoder.image(from: data) {
                Image(decorative: image, scale: 1, orientation: .up).resizable().scaledToFill()
            } else {
                DemoThumbnail(category: item.category)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.black.opacity(0.06), lineWidth: 1) }
    }
}

private enum ThumbnailDecoder {
    static func image(from data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
}

private struct DemoThumbnail: View {
    let category: ScreenshotCategory
    var body: some View {
        ZStack {
            LinearGradient(colors: [.indigo.opacity(0.9), .cyan.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(spacing: 10) {
                Image(systemName: category.symbolName).font(.title.bold())
                RoundedRectangle(cornerRadius: 2).fill(.white.opacity(0.75)).frame(width: 48, height: 4)
                RoundedRectangle(cornerRadius: 2).fill(.white.opacity(0.45)).frame(width: 36, height: 4)
            }.foregroundStyle(.white)
        }
    }
}
