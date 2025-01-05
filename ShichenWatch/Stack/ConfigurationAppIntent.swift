import AppIntents
import WidgetKit

// MARK: - ConfigurationAppIntent

@available(watchOS 10.0, *)
struct ConfigurationAppIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Configuration"
  static let description: IntentDescription? = IntentDescription("TianganDizhi Widgets")

  @Parameter(title: "Date")
  var date: DateComponents

  @Parameter(title: "Location")
  var location: String
}

// MARK: - SimpleAppIntentEntry

@available(watchOS 10.0, *)
struct SimpleAppIntentEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationAppIntent
}
