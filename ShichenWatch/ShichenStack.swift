import WidgetKit
import AppIntents
import SwiftUI

@available(watchOSApplicationExtension 10.0, *)
struct SimpleAppIntentEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationAppIntent
  
  var relevance: TimelineEntryRelevance? {
    nil
  }
}

@available(watchOSApplicationExtension 10.0, *)
struct ShiChenStack: Widget {

  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: "ShiChenStack", intent: ConfigurationAppIntent.self, provider: AppIntentsTimelineProvider()) { entry in
      MediumWidgetView(date: entry.date)
    }
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
