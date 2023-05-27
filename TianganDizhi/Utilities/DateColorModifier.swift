import SwiftUI

// MARK: - AutoColorPastDate

struct AutoColorPastDate: ViewModifier {
  let date: Date?
  let now: Date

  func body(content: Content) -> some View {
    guard let date else {
      return content.foregroundColor(.primary)
    }
    return content
      .foregroundColor(date <= now ? .secondary : .primary)
  }
}

extension View {
  func autoColorPastDate(_ date: Date?, now: Date = Date()) -> some View {
    modifier(AutoColorPastDate(date: date, now: now))
  }
}
