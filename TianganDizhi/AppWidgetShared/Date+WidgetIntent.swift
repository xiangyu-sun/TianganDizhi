import Foundation

extension Date {
  var currentCalendarDateCompoenents: DateComponents {
    Calendar.current.dateComponents(in: .current, from: self)
  }

}

extension DateComponents {
  /// Whether this configured date falls in the shichen that is active right
  /// now — used to decide which widgets need a timeline reload after a
  /// weather refresh.
  ///
  /// The widget's configured date is stored as full `DateComponents` down to
  /// the nanosecond (see the `IntentTimelineProvider`s' `configuration.date =
  /// Date().currentCalendarDateCompoenents`), so comparing for exact equality
  /// against "now" could essentially never match. Comparing which shichen
  /// each date falls in — same calendar day, same 地支 — is what "same
  /// shichen" actually means.
  var isSameWithCurrentShichen: Bool {
    isSameShichen(as: Date())
  }

  func isSameShichen(as now: Date) -> Bool {
    guard let date = Calendar.current.date(from: self) else { return false }
    guard let configuredShichen = date.shichen, let currentShichen = now.shichen else { return false }
    return Calendar.current.isDate(date, inSameDayAs: now) && configuredShichen.dizhi == currentShichen.dizhi
  }
}
