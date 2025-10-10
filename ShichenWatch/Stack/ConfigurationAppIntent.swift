import AppIntents
import WidgetKit

// MARK: - ConfigurationAppIntent

struct ConfigurationAppIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Configuration"
  static let description: IntentDescription? = IntentDescription("TianganDizhi Widgets")

  @Parameter(title: "Date")
  var date: DateComponents?

  @Parameter(title: "Location")
  var location: String?
}

// MARK: - SimpleAppIntentEntry

struct SimpleAppIntentEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationAppIntent
}
