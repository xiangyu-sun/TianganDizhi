//
//  ShiChenYearMonthDateEntryView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 12/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar
import WidgetKit

struct ShiChenYearMonthDateEntryView : View {
    var entry: SimpleEntry
    @Environment(\.bodyFont) var bodyFont
    @Environment(\.titleFont) var titleFont
    @Environment(\.title3Font) var title3Font
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        let shichen = try! GanzhiDateConverter.shichen(entry.date)
        
        switch family {
        case .accessoryInline:
            if #available(iOSApplicationExtension 16.0, *) {
                InlineWidgetView(date: entry.date)
            }
        case .accessoryCircular:
            if #available(iOSApplicationExtension 16.0, *) {
                CircularWidgetView(date: entry.date)
            }
        case .accessoryRectangular:
            if #available(iOSApplicationExtension 16.0, *) {
                RetangularWidgetView(date: entry.date)
            }
        default:
            VStack() {
                Spacer()
                Text(entry.date.displayStringOfChineseYearMonthDateWithZodiac)
                    .font(bodyFont)
                    .padding([.leading,.trailing], 15)
                Text(shichen.displayHourText)
                    .font(titleFont)
                Spacer()
            }
        }
        
    }
}

struct ShiChenYearMonthDateEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
#if os(watchOS)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
#else
                .previewContext(WidgetPreviewContext(family: .systemSmall))
#endif
                .previewDisplayName("Small")
            
            ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
#if os(watchOS)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
#else
                .previewContext(WidgetPreviewContext(family: .systemMedium))
#endif
                .previewDisplayName("Medium")
        }
#if os(iOS)
        if #available(iOSApplicationExtension 16.0, *) {
            Group {
                ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                    .previewContext(WidgetPreviewContext(family: .accessoryInline))
                    .previewDisplayName("ShiChenYearMonthDateEntryView Inline")
                
                ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                    .previewDisplayName("ShiChenYearMonthDateEntryView Circular")
                
                ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                    .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                    .previewDisplayName("ShiChenYearMonthDateEntryView Retangular")
                
            }
        }
#endif
    }
}

