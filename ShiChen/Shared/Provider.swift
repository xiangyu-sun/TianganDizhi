import WidgetKit
import ChineseAstrologyCalendar

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }
    
    func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
        return defaultDecommendedIntents().map { intent in
            return IntentRecommendation(intent: intent, description: "")
        }
    }
    
    private func defaultDecommendedIntents() -> [ConfigurationIntent] {
        return [ConfigurationIntent()]
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        for date in TimeLineSceduler.buildTimeLine() {
            let entry = SimpleEntry(date: date, configuration: configuration)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
