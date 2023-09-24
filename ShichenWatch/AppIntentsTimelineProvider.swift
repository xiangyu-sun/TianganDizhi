import ChineseAstrologyCalendar
import CoreLocation
import AppIntents
import WidgetKit

@available(watchOSApplicationExtension 10.0, *)
struct AppIntentsTimelineProvider: AppIntentTimelineProvider {

  
  // MARK: Internal

  func placeholder(in _: Context) -> SimpleAppIntentEntry {
    let configuration = ConfigurationAppIntent()
    configuration.date = Date().currentCalendarDateCompoenents
    if let location = LocationManager.shared.lastLocation {
      configuration.location = "\(String(describing: location))"
    }

    return SimpleAppIntentEntry(date: Date(), configuration: configuration)
  }

  func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
    defaultRecommendedIntents().map { intent in
      let description = Date().shichen?.dizhi.chineseCharactor ?? ""
      return AppIntentRecommendation(intent: intent, description: description)
    }
  }

  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleAppIntentEntry {
    let entry = SimpleAppIntentEntry(date: Date(), configuration: configuration)
    
    return entry
  }
  
  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleAppIntentEntry> {
    var entries: [Entry] = []

    configuration.date = Calendar.current.dateComponents(in: .current, from: Date())
    if let location = LocationManager.shared.lastLocation {
      configuration.location = "\(String(describing: location))"
    }

    for date in ShichenTimeLineSceduler.buildTimeLine() {
      let entry = SimpleAppIntentEntry(date: date, configuration: configuration)
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    
    return timeline
  }

  // MARK: Private

  private func defaultRecommendedIntents() -> [ConfigurationAppIntent] {
    let configuration = ConfigurationAppIntent()
    configuration.date = Date().currentCalendarDateCompoenents
    if let location = LocationManager.shared.lastLocation {
      configuration.location = "\(String(describing: location))"
    }
    return [configuration]
  }
}
