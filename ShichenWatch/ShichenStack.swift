import WidgetKit
import AppIntents
import SwiftUI

@available(watchOS 10.0, *)
struct ShiChenStackWidget: Widget {
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: "ShiChenStack", intent: ConfigurationAppIntent.self, provider: AppIntentsTimelineProvider()) { entry in
      WatchStackView(date: entry.date)
    }
    .configurationDisplayName(WidgetConstants.normalWidgetDisplayName)
    .description(WidgetConstants.normalWidgetDescription)
    .supportedFamilies([.accessoryRectangular])
  }
}

@available(watchOS 10.0, *)
#Preview(
  as: .accessoryRectangular,
  widget: {
    ShiChenStackWidget()
  },
  timeline: {
    SimpleAppIntentEntry(date: Date(), configuration: .init())
  }
)
