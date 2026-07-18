import Foundation
import ImageIO
import UniformTypeIdentifiers

@MainActor
final class ThumbnailService {
    func thumbnail(from sourceData: Data, maximumPixelSize: Int = 720) throws -> Data {
        guard let source = CGImageSourceCreateWithData(sourceData as CFData, nil) else { throw AppError.corruptedImage }
        let options: [CFString: Any] = [kCGImageSourceCreateThumbnailFromImageAlways: true, kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize, kCGImageSourceCreateThumbnailWithTransform: true]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { throw AppError.corruptedImage }
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.jpeg.identifier as CFString, 1, nil) else { throw AppError.corruptedImage }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw AppError.corruptedImage }
        return output as Data
    }
}
