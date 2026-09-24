import AppIntents
import ChineseAstrologyCalendar
import WidgetKit

struct AppIntentsTimelineProvider: @preconcurrency AppIntentTimelineProvider {

  // MARK: Internal

  @MainActor
  func placeholder(in _: Context) -> SimpleAppIntentEntry {
    SimpleAppIntentEntry(date: Date(), configuration: ConfigurationAppIntent())
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
    // Nothing reads `configuration.date`/`.location`, so entries carry the
    // widget's own configuration instead of scratch values (writing the
    // location put precise coordinates into the persisted intent).
    let entries = ShichenTimeLineSceduler.buildTimeLine().map {
      SimpleAppIntentEntry(date: $0, configuration: configuration)
    }
    return Timeline(entries: entries, policy: .atEnd)
  }

  // MARK: Private

  @MainActor
  private func defaultRecommendedIntents() -> [ConfigurationAppIntent] {
    [ConfigurationAppIntent()]
  }
}
