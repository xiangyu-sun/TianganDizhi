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
            ViewThatFits() {
                Text("\(entry.date.displayStringOfChineseYearMonthDateWithZodiac) \(shichen.displayHourText)")
                Text(shichen.displayHourText)
                
            }
            .font(bodyFont)
            .widgetAccentable()
        case .accessoryCircular:
            ProgressView(interval: (shichen.startDate ?? Date())...(shichen.endDate ?? Date()),
                         countdown: false,
                         label: {
                Text(shichen.displayHourText)
                    .widgetAccentable()
            }, currentValueLabel: {
#if os(watchOS)
                Text(shichen.displayHourText)
                    .widgetAccentable()
#endif
                
            })
            .progressViewStyle(.circular)
        case .accessoryRectangular:
            HStack() {
                Text(entry.date.displayStringOfChineseYearMonthDateWithZodiac)
                    .font(bodyFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
          
                Text(shichen.displayHourText)
                    .widgetAccentable()
#if os(watchOS)
                    .font(titleFont)
#else
                    .font(title3Font)
#endif
                  
            }
            .widgetAccentable()
        default:
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
}

struct ShiChenYearMonthDateEntryView_Previews: PreviewProvider {
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
        }
    }
}

