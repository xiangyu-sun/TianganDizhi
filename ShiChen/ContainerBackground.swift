import SwiftUI


extension View {
  func containerBackgroundForWidget<V>(alignment: Alignment = .center,
                                      @ViewBuilder content: () -> V
  ) -> some View where V : View {
    if #available(iOS 17.0, watchOS 10.0, macOS 14.0, *) {
      return containerBackground(for: .widget, content: content)
    } else {
      return EmptyView()
    }
  }
}
