import SwiftUI

// MARK: - AutoColorPastDate

struct AutoColorPastDate: ViewModifier {
  let date: Date?

  func body(content: Content) -> some View {
    guard let date else {
      return content.foregroundColor(.primary)
    }
    return content
      .foregroundColor(date <= Date() ? .secondary : .primary)
  }
}

extension View {
  func autoColorPastDate(_ date: Date?) -> some View {
    modifier(AutoColorPastDate(date: date))
  }
}
