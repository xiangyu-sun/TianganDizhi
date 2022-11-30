import ChineseAstrologyCalendar
import WidgetKit

struct ShichenTimelineProvider: IntentTimelineProvider {

  // MARK: Internal

  func placeholder(in _: Context) -> SimpleEntry {
    SimpleEntry(date: Date.now, configuration: ConfigurationIntent())
  }

  @available(iOSApplicationExtension 16.0, *)
  func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
    defaultDecommendedIntents().map { intent in
      let description = (try? GanzhiDateConverter.shichen(Date.now).chineseCharactor) ?? ""
      return IntentRecommendation(intent: intent, description: description)
    }
  }

  func getSnapshot(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (SimpleEntry) -> Void) {
    let entry = SimpleEntry(date: Date.now, configuration: configuration)
    completion(entry)
  }

  func getTimeline(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
    var entries: [SimpleEntry] = []

    for date in ShichenTimeLineSceduler.buildTimeLine() {
      let entry = SimpleEntry(date: date, configuration: configuration)
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }

  // MARK: Private

  private func defaultDecommendedIntents() -> [ConfigurationIntent] {
    [ConfigurationIntent()]
  }
}
