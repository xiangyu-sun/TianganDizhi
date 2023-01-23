import WidgetKit

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
}


struct CountDownEntry: TimelineEntry {
  let date: Date
  let configuration: CountDownIntentConfigurationIntent
}
