import Foundation
import Vision
import ImageIO

final class OCRService {
    func analyze(_ imageData: Data) async throws -> OCRResult {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil), let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { throw AppError.corruptedImage }
        return try await Task.detached(priority: .userInitiated) {
            let textRequest = VNRecognizeTextRequest()
            textRequest.recognitionLevel = .accurate
            textRequest.usesLanguageCorrection = true
            textRequest.minimumTextHeight = 0.012
            let barcodeRequest = VNDetectBarcodesRequest()
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            try handler.perform([textRequest, barcodeRequest])
            let text = textRequest.results?.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n") ?? ""
            let codes = barcodeRequest.results?.compactMap(\.payloadStringValue) ?? []
            return OCRResult(text: text, qrPayloads: codes)
        }.value
    }
}

nonisolated struct OCRResult: Sendable {
    let text: String
    let qrPayloads: [String]
}
