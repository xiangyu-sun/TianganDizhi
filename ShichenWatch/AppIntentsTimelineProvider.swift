import AppIntents
import ChineseAstrologyCalendar
import CoreLocation
import WidgetKit

struct AppIntentsTimelineProvider: @preconcurrency AppIntentTimelineProvider {

  // MARK: Internal

  @MainActor
  func placeholder(in _: Context) -> SimpleAppIntentEntry {
    let configuration = ConfigurationAppIntent()
    configuration.date = Date().currentCalendarDateCompoenents
    if let location = LocationManager.shared.lastLocation {
      configuration.location = "\(String(describing: location))"
    }

    return SimpleAppIntentEntry(date: Date(), configuration: configuration)
  }

  @MainActor
  func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
    defaultRecommendedIntents().map { intent in
      let description = String(describing: "天干地支小組件 - \(Date().shichen?.dizhi.chineseCharacter ?? "")")
      return AppIntentRecommendation(intent: intent, description: description)
    }
  }

  func snapshot(for configuration: ConfigurationAppIntent, in _: Context) async -> SimpleAppIntentEntry {
    SimpleAppIntentEntry(date: Date(), configuration: configuration)
  }

  func timeline(for configuration: ConfigurationAppIntent, in _: Context) async -> Timeline<SimpleAppIntentEntry> {
    var entries: [Entry] = []

    let location = await LocationManager.shared.lastLocation

    for date in ShichenTimeLineSceduler.buildTimeLine() {
      let config = ConfigurationAppIntent()
      config.date = Calendar.current.dateComponents(in: .current, from: date)
      if let location {
        config.location = "\(String(describing: location))"
      }
      let entry = SimpleAppIntentEntry(date: date, configuration: config)
      entries.append(entry)
    }

    return Timeline(entries: entries, policy: .atEnd)
  }

  // MARK: Private

  @MainActor
  private func defaultRecommendedIntents() -> [ConfigurationAppIntent] {
    let configuration = ConfigurationAppIntent()
    configuration.date = Date().currentCalendarDateCompoenents
    if let location = LocationManager.shared.lastLocation {
      configuration.location = "\(String(describing: location))"
    }
    return [configuration]
  }
}
