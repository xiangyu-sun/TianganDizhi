import SwiftUI
import WidgetKit

// MARK: - AllWidgets

@main
struct AllWidgets: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    ShiChenWidget()
    HourlyWidget()
    ShiChenStackWidget()
  }
}
