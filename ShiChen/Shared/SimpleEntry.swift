import WidgetKit

// MARK: - SimpleEntry

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
}

// MARK: - CountDownEntry

struct CountDownEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
}
