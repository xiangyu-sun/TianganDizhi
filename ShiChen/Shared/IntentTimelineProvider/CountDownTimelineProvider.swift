import WidgetKit

struct CountDownTimelineProvider: IntentTimelineProvider {

  // MARK: Internal

  typealias Entry = CountDownEntry
  typealias Intent = ConfigurationIntent

  func placeholder(in _: Context) -> CountDownEntry {
    CountDownEntry(date: Date(), configuration: Intent())
  }

  func recommendations() -> [IntentRecommendation<Intent>] {
    defaultRecommendedIntents().map { intent in
      let description = Date().shichen?.dizhi.chineseCharactor ?? ""
      return IntentRecommendation(intent: intent, description: description)
    }
  }

  func getSnapshot(for configuration: Intent, in _: Context, completion: @escaping (CountDownEntry) -> Void) {
    let entry = CountDownEntry(date: Date(), configuration: configuration)
    completion(entry)
  }

  func getTimeline(for configuration: Intent, in _: Context, completion: @escaping (Timeline<CountDownEntry>) -> Void) {
    var entries: [CountDownEntry] = []

    for date in MinuteTimeLineScheduler.buildTimeLine() {
      let entry = CountDownEntry(date: date, configuration: configuration)
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }

  // MARK: Private

  private func defaultRecommendedIntents() -> [Intent] {
    [Intent()]
  }
}
