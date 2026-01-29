import ChineseAstrologyCalendar
import CoreLocation
import WidgetKit
@MainActor
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

  func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
    defaultRecommendedIntents().map { intent in
      let description = Date().shichen?.dizhi.chineseCharacter ?? ""
      return IntentRecommendation(intent: intent, description: "當前時辰" + description)
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

  @available(macOSApplicationExtension 15.0, *)
  @available(watchOSApplicationExtension 11.0, *)
  @available(iOSApplicationExtension 18.0, *)
  func relevance() async -> WidgetRelevance<ConfigurationIntent> {
    .init([.init(configuration: ConfigurationIntent(), context: .date(Date()))])
  }

  // MARK: Private

  private func defaultRecommendedIntents() -> [ConfigurationIntent] {
    let configuration = ConfigurationIntent()
    configuration.date = Date().currentCalendarDateCompoenents
    if let location = LocationManager.shared.lastLocation {
      configuration.location = "\(String(describing: location))"
    }
    return [configuration]
  }
}
