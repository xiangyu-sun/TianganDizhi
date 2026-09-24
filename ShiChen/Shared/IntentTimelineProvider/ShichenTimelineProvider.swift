import ChineseAstrologyCalendar
@preconcurrency import WidgetKit
struct ShichenTimelineProvider: IntentTimelineProvider {

  // MARK: Internal

  func placeholder(in _: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), configuration: ConfigurationIntent())
  }

  func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
    defaultRecommendedIntents().map { intent in
      let description = Date().shichen?.dizhi.chineseCharacter ?? ""
      return IntentRecommendation(intent: intent, description: "當前時辰" + description)
    }
  }

  func getSnapshot(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (SimpleEntry) -> Void) {
    completion(entry(at: Date(), configuration: configuration))
  }

  func getTimeline(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
    // `configuration.date`/`.location` are not user-configurable; nothing
    // reads them, so they are left alone rather than filled with scratch
    // values (writing the location put precise coordinates into the persisted
    // intent).
    var entries: [SimpleEntry] = []
    for date in ShichenTimeLineSceduler.buildTimeLine() {
      entries.append(entry(at: date, configuration: configuration))
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

  /// An entry carrying the app's cached forecast when it is for `date`'s day.
  private func entry(at date: Date, configuration: ConfigurationIntent) -> SimpleEntry {
    var entry = SimpleEntry(date: date, configuration: configuration)
    #if os(iOS) || os(macOS)
    entry.weather = WeatherData.cachedForecast(on: date)
    #endif
    return entry
  }


  private func defaultRecommendedIntents() -> [ConfigurationIntent] {
    [ConfigurationIntent()]
  }
}
