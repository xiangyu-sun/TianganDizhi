import WidgetKit

// MARK: - SimpleEntry

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
  #if os(iOS) || os(macOS)
  /// The app's cached forecast for this entry's day, or `nil` when there is
  /// none. Widgets can't fetch weather themselves (no location permission in the
  /// extension), so the timeline provider hands over what the app last stored.
  var weather: WeatherData.Information? = nil
  #endif
}

// MARK: - CountDownEntry

struct CountDownEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
}
