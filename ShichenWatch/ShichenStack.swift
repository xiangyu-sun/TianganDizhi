import WidgetKit
import AppIntents
import SwiftUI

@available(watchOS 10.0, *)
struct SimpleAppIntentEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationAppIntent
}

@available(watchOS 10.0, *)
struct ShiChenStackWidget: Widget {
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: "ShiChenStack", intent: ConfigurationAppIntent.self, provider: AppIntentsTimelineProvider()) { entry in
      MediumWidgetView(date: entry.date)
    }
    .configurationDisplayName(WidgetConstants.normalWidgetDisplayName)
    .description(WidgetConstants.normalWidgetDescription)
    .supportedFamilies([.accessoryRectangular])
  }
}
//
//#Preview(
//  as: .accessoryRectangular,
//  widget: {
//    ShiChenStackWidget()
//  },
//  timeline: {
//    SimpleAppIntentEntry(date: Date(), configuration: .init())
//  }
//)
