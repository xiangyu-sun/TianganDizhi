import SwiftUI
import WidgetKit

// MARK: - AllWidgets

@main
struct AllWidgets: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    ShiChen()
    HourlyWidget()
    if #available(watchOS 10.0, *) {
      ShiChenStackWidget()
    }
  }
}