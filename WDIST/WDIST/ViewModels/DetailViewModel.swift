import Foundation
import Observation

@MainActor
@Observable
final class DetailViewModel {
    let item: ScreenshotItem
    var didRequestCopy = false
    init(item: ScreenshotItem) { self.item = item }

    func prepareCopy() { didRequestCopy = true }
}
