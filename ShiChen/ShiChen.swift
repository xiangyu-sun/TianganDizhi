//
//  ShiChen.swift
//  ShiChen
//
//  Created by 孙翔宇 on 02/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
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

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}


struct FullDateTitleView: View {
    @Environment(\.bodyFont) var bodyFont
    @Environment(\.titleFont) var titleFont
    var date: Date
    var body: some View {
        HStack(){
            Text((try? GanzhiDateConverter.zodiac(date).rawValue) ?? "")
                .font(bodyFont)
            Text(date.chineseYearMonthDate)
                .font(bodyFont)
        }
    }
}

struct Nongli: Widget {
    let kind: String = "Nongli"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            ShiChenYearMonthDateEntryView(entry: entry)
        }
        .configurationDisplayName("年月日時辰")
        .description("農曆年月日以及十二時辰")
#if os(watchOS)
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular])
#else
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge,  .accessoryInline, .accessoryCircular, .accessoryRectangular])
#endif
    
        
    }
}

struct ShiChen: Widget {
    let kind: String = "ShiChen"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            ShiChenEntryView(entry: entry)
        }
        .configurationDisplayName("十二时辰")
        .description("十二地支为名的十二时辰计，俗稱，以及相關臟器")
#if os(watchOS)
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular])
#else
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge,  .accessoryInline, .accessoryCircular, .accessoryRectangular])
#endif
        
    }
}

@main
struct AllWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ShiChen()
        Nongli()
    }
}

struct ShiChen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("YearMonth Inline")
            
            ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("YearMonth Circular")
            
            ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("YearMonth Retangular")
            
            ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Inline")
            
            ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Circular")
            
            ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Retangular")
        }
#if os(iOS)
        Group {
            ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .environment(\.colorScheme, .dark)
            ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            
            ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.sizeCategory, .extraExtraLarge)
        }
#endif
    }
}
