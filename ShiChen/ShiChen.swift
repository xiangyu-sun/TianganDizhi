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

struct Nongli: Widget {
    let kind: String = "Nongli"
    
    var supportedFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium,  .accessoryInline, .accessoryCircular, .accessoryRectangular]
        }else {
            return [.systemSmall, .systemMedium]
        }
    }
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: ShichenTimelineProvider()) { entry in
            ShiChenYearMonthDateEntryView(entry: entry)
        }
        .configurationDisplayName("年月日時辰")
        .description("農曆年月日以及十二時辰")
#if os(watchOS)
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular])
#else
        
        .supportedFamilies(supportedFamilies)
#endif
    
        
    }
}

struct ShiChen: Widget {
    let kind: String = "ShiChen"
    
    var supportedFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge,  .accessoryInline, .accessoryRectangular]
        }else {
            return [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
        }
    }
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: ShichenTimelineProvider()) { entry in
            ShiChenEntryView(entry: entry)
        }
        .configurationDisplayName("十二时辰")
        .description("十二地支为名的十二时辰计，俗稱，以及相關臟器")
#if os(watchOS)
        .supportedFamilies([.accessoryInline, .accessoryRectangular])
#else
        .supportedFamilies(supportedFamilies)
#endif
        
    }
}

@available(iOSApplicationExtension 16.0, *)
struct HourlyWidget: Widget {
    let kind: String = "ShiChenByMinute"
    
    var supportedFamilies: [WidgetFamily] {
        return [.accessoryCircular]
    }
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: MinuteTimelineProvider()) { entry in
            ShiChenEntryView(entry: entry)
        }
        .configurationDisplayName("十二时辰")
        .description("十二地支为名的十二时辰組件")
        .supportedFamilies([.accessoryCircular])
    }
}


struct ShiChen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            if #available(iOSApplicationExtension 16.0, *) {
                ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                    .previewContext(WidgetPreviewContext(family: .accessoryInline))
                    .previewDisplayName("ShiChenEntryView Inline")
                ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                    .previewDisplayName("ShiChenEntryView Circular")
                
                ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                    .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                    .previewDisplayName("ShiChenEntryView Retangular")
            }
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
                .previewDisplayName("systemExtraLarge")
            
            ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.sizeCategory, .extraExtraLarge)
        }
#endif
    }
}
