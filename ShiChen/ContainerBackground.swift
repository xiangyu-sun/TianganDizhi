import SwiftUI

extension View {
  func containerBackgroundForWidget(
    @ViewBuilder content: @escaping () -> some View)
    -> some View
  {
    modifier(WidgetContainerBackground(backgroundContent: content))
  }
}

struct WidgetContainerBackground<V: View>: ViewModifier {

  var backgroundContent: () -> V

  func body(content: Content) -> some View {
    if #available(iOS 17.0, watchOS 10.0, macOS 14.0, *) {
      return content.containerBackground(for: .widget, content: backgroundContent)
    } else {
      return content
    }
  }
}
