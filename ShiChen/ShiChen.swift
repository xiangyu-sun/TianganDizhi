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
        
        let currentDate = Date()
        
        let entry = SimpleEntry(date: currentDate, configuration: configuration)
        entries.append(entry)
        
        let next = try? GanzhiDateConverter.shichen(currentDate).secondToNextShiChen()
        let nextDate = Date(timeIntervalSinceNow: next!)
        let nextEntry = SimpleEntry(date: nextDate, configuration: configuration)
        entries.append(nextEntry)
        
        for hourOffset in 1 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset * 2, to: nextDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
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
    
    var body: some View {
        let shichen = try! GanzhiDateConverter.shichen(entry.date)
        
        switch family {
        case .systemMedium:
            VStack() {
                titleView
                ShichenHStackView(shichen: shichen)
                .padding()
            }
        case .systemLarge:
            VStack() {
                titleView
                ClockView(currentShichen: shichen)
                    .padding()
            }
        default:
            VStack() {
                titleView
                Text(shichen.displayHourText)
                    .font(.defaultLargeTitle)
                Text(shichen.aliasName)
                    .font(.defaultBody)
                Spacer()
            }
        }
        
    }
    
    private var titleView: some View {
        HStack(){
            Text((try? GanzhiDateConverter.nian(entry.date).formatedYear) ?? "")
                .font(.defaultBody)
            Text((try? GanzhiDateConverter.zodiac(entry.date).rawValue) ?? "")
                .font(.defaultBody)
        }
    }
}

@main
struct ShiChen: Widget {
    let kind: String = "ShiChen"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            ShiChenEntryView(entry: entry)
        }
        .configurationDisplayName("十二时辰")
        .description("十二地支为名的十二时辰计时法")
        
    }
}

struct ShiChen_Previews: PreviewProvider {
    static var previews: some View {
        ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
