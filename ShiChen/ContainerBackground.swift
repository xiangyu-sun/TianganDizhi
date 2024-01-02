import SwiftUI

extension View {
  func containerBackgroundForWidget(
    alignment _: Alignment = .center,
    @ViewBuilder content: () -> some View)
    -> some View
  {
    if #available(iOS 17.0, watchOS 10.0, macOS 14.0, *) {
      return containerBackground(for: .widget, content: content)
    } else {
      return EmptyView()
    }
  }
}
