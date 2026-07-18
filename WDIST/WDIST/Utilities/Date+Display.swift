import Foundation

extension Date {
    var memoryDisplay: String {
        if Calendar.current.isDateInToday(self) { return "Today" }
        if Calendar.current.isDateInYesterday(self) { return "Yesterday" }
        return formatted(.dateTime.month(.abbreviated).day().year())
    }
}
