import WidgetKit
import AppIntents
import SwiftUI

@available(watchOSApplicationExtension 10.0, *)
struct SimpleAppIntentEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationAppIntent
}

@available(watchOSApplicationExtension 10.0, *)
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

@available(watchOSApplicationExtension 10.0, *)
struct ShiChenStack_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      WatchStackView(date: Date())
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
  }
}
