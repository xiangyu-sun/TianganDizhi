import AppIntents
import WidgetKit

@available(watchOS 10.0, *)
struct ConfigurationAppIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource = "Configuration"
  static var description: IntentDescription? = IntentDescription("TianganDizhi Widgets")
  
  @Parameter(title: "Date")
  var date: DateComponents
  
  @Parameter(title: "Location")
  var location: String
}

@available(watchOS 10.0, *)
struct SimpleAppIntentEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationAppIntent
}