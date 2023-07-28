import Foundation

extension Date {
  var currentCalendarDateCompoenents: DateComponents {
    Calendar.current.dateComponents(in: .current, from: self)
  }

}

extension DateComponents {
  var isSameWithCurrentShichen: Bool {
    self == Calendar.current.dateComponents(in: .current, from: Date().shichen?.startDate ?? Date())
  }
}
