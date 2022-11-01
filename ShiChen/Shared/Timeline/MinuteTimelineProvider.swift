import WidgetKit
import ChineseAstrologyCalendar

struct MinuteTimelineProvider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date.now, configuration: ConfigurationIntent())
    }
    
    @available(iOSApplicationExtension 16.0, *)
    func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
        return defaultDecommendedIntents().map { intent in
          let description = (try? GanzhiDateConverter.shichen(Date.now).chineseCharactor) ?? ""
          return IntentRecommendation(intent: intent, description: description)
        }
    }
    
    private func defaultDecommendedIntents() -> [ConfigurationIntent] {
        return [ConfigurationIntent()]
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
      let entry = SimpleEntry(date: Date.now, configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        for date in MinuteTimeLineScheduler.buildTimeLine() {
            let entry = SimpleEntry(date: date, configuration: configuration)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
