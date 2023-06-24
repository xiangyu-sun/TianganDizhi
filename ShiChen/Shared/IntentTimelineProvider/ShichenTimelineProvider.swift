import ChineseAstrologyCalendar
import WidgetKit
import CoreLocation

struct ShichenTimelineProvider: IntentTimelineProvider {

  // MARK: Internal

  func placeholder(in _: Context) -> SimpleEntry {
    let configuration = ConfigurationIntent()
    configuration.date = Date().currentCalendarDateCompoenents
    if let location = LocationManager.shared.lastLocation {
      configuration.location = "\(String(describing: location))"
    }
    
    return SimpleEntry(date: Date(), configuration: configuration)
  }

  @available(iOSApplicationExtension 16.0, *, watchOS 9, *)
  func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
    defaultRecommendedIntents().map { intent in
      let description = Date().shichen?.dizhi.chineseCharactor ?? ""
      return IntentRecommendation(intent: intent, description: description)
    }
  }

  func getSnapshot(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (SimpleEntry) -> Void) {
    let entry = SimpleEntry(date: Date(), configuration: configuration)
    completion(entry)
  }

  func getTimeline(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
    var entries: [SimpleEntry] = []
    
    configuration.date = Calendar.current.dateComponents(in: .current, from: Date())
    if let location = LocationManager.shared.lastLocation {
      configuration.location = "\(String(describing: location))"
    }
    
    for date in ShichenTimeLineSceduler.buildTimeLine() {
      let entry = SimpleEntry(date: date, configuration: configuration)
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }

  // MARK: Private

  private func defaultRecommendedIntents() -> [ConfigurationIntent] {
    [ConfigurationIntent()]
  }
}
