import WidgetKit

struct CountDownTimelineProvider: IntentTimelineProvider {
  typealias Entry = CountDownEntry
  typealias Intent = CountDownIntentConfigurationIntent
  

  // MARK: Internal

  func placeholder(in _: Context) -> CountDownEntry {
    CountDownEntry(date: Date(), configuration: CountDownIntentConfigurationIntent())
  }

  @available(iOSApplicationExtension 16.0, *, watchOS 9, *)
  func recommendations() -> [IntentRecommendation<CountDownIntentConfigurationIntent>] {
    defaultRecommendedIntents().map { intent in
      let description = Date().shichen?.dizhi.chineseCharactor ?? ""
      return IntentRecommendation(intent: intent, description: description)
    }
  }

  func getSnapshot(for configuration: CountDownIntentConfigurationIntent, in _: Context, completion: @escaping (CountDownEntry) -> Void) {
    let entry = CountDownEntry(date: Date(), configuration: configuration)
    completion(entry)
  }

  func getTimeline(for configuration: CountDownIntentConfigurationIntent, in _: Context, completion: @escaping (Timeline<CountDownEntry>) -> Void) {
    var entries: [CountDownEntry] = []

    for date in MinuteTimeLineScheduler.buildTimeLine() {
      let entry = CountDownEntry(date: date, configuration: configuration)
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }

  // MARK: Private

  private func defaultRecommendedIntents() -> [CountDownIntentConfigurationIntent] {
    [CountDownIntentConfigurationIntent()]
  }
}
