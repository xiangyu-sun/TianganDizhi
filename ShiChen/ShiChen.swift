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
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
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

struct ShiChenEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.largeTitleFont) var largeTitleFont
    @Environment(\.bodyFont) var bodyFont
    var body: some View {
        let shichen = try! GanzhiDateConverter.shichen(entry.date)
        
        switch family {
        case .systemMedium:
            VStack() {
                FullDateTitleView(date: entry.date)
                ShichenHStackView(shichen: shichen)
                    .padding([.leading, .trailing], 8)
            }
        case .systemLarge:
            VStack() {
                FullDateTitleView(date: entry.date)
                ClockView(currentShichen: shichen, padding: 0)
            }
        default:
            VStack() {
                titleView
                Text(shichen.displayHourText)
                .font(largeTitleFont)
                
                ShichenInformationView(shichen: shichen)
            }
        }
        
    }
    
    private var titleView: some View {
        HStack(){
            Text((try? GanzhiDateConverter.nian(entry.date).formatedYear) ?? "")
                .font(bodyFont)
            Text((try? GanzhiDateConverter.zodiac(entry.date).rawValue) ?? "")
                .font(bodyFont)
        }
    }
}

struct ShiChenYearMonthDateEntryView : View {
    var entry: Provider.Entry
    @Environment(\.bodyFont) var bodyFont
    @Environment(\.titleFont) var titleFont
    var body: some View {
        let shichen = try! GanzhiDateConverter.shichen(entry.date)
        
        VStack() {
            Spacer()
            Text(entry.date.chineseYearMonthDate)
                .font(bodyFont)
                .padding([.leading,.trailing], 15)
            Text(shichen.displayHourText)
                .font(titleFont)
            Spacer()
        }
    }
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
        .supportedFamilies([.systemSmall])
        
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
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.sizeCategory, .extraExtraLarge)

    }
}
