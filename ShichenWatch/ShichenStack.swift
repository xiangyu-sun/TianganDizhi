import AppIntents
import SwiftUI
import WidgetKit

struct ShiChenStackWidget: Widget {

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: "ShiChenStack",
      intent: ConfigurationAppIntent.self,
      provider: AppIntentsTimelineProvider())
    { entry in
      WatchStackView(date: entry.date)
    }
    .configurationDisplayName(WidgetConstants.normalWidgetDisplayName)
    .description(WidgetConstants.normalWidgetDescription)
    .supportedFamilies([.accessoryRectangular])
  }
}

#Preview(
  as: .accessoryRectangular,
  widget: {
    ShiChenStackWidget()
  },
  timeline: {
    SimpleAppIntentEntry(date: Date(), configuration: .init())
  })
