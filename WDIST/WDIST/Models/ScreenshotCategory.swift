import Foundation

nonisolated enum ScreenshotCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case jobPost = "Job Posts"
    case qrCode = "QR Codes"
    case receipt = "Receipts"
    case ticket = "Tickets"
    case recipe = "Recipes"
    case meme = "Memes"
    case note = "Notes"
    case map = "Maps"
    case otp = "OTP"
    case eventPoster = "Event Posters"
    case shopping = "Shopping"
    case other = "Other"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .jobPost: "briefcase.fill"
        case .qrCode: "qrcode"
        case .receipt: "receipt"
        case .ticket: "ticket.fill"
        case .recipe: "fork.knife"
        case .meme: "face.smiling"
        case .note: "note.text"
        case .map: "map.fill"
        case .otp: "number.square.fill"
        case .eventPoster: "calendar"
        case .shopping: "bag.fill"
        case .other: "square.grid.2x2.fill"
        }
    }

    nonisolated static func resolved(_ value: String) -> ScreenshotCategory {
        allCases.first { $0.rawValue.caseInsensitiveCompare(value) == .orderedSame } ?? .other
    }
}
