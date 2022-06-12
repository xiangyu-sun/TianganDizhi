//
//  ShiChenEntryView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 12/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar
import WidgetKit

struct ShiChenEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.largeTitleFont) var largeTitleFont
    @Environment(\.bodyFont) var bodyFont
    @Environment(\.titleFont) var titleFont
    
    var body: some View {
        let shichen = try! GanzhiDateConverter.shichen(entry.date)
        
        switch family {
        case .accessoryInline:
            ViewThatFits() {
                HStack() {
                    Text(entry.date.chineseYearMonthDate)
                        .font(bodyFont)
                        .padding([.leading,.trailing], 15)
                    Text(shichen.displayHourText)
                        .font(titleFont)
                        .widgetAccentable()
                }
                Text(shichen.displayHourText)
                    .font(titleFont)
                    .widgetAccentable()
            }
        case .accessoryCircular:
            ProgressView(value: 0.2) {
                Text(shichen.displayHourText)
                    .font(titleFont)
                    .widgetAccentable()
            }.progressViewStyle(.circular)
            //TODO: change to live update API
        case .accessoryRectangular:
            HStack() {
                VStack() {
                    Text(entry.date.chineseYearMonthDate)
                        .font(bodyFont)
                  
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(shichen.displayHourText)
                    .font(bodyFont)
                    .widgetAccentable()
            }
        case .systemMedium:
            VStack() {
                FullDateTitleView(date: entry.date)
                ShichenHStackView(shichen: shichen)
                    .padding([.leading, .trailing], 8)
            }
        case .systemLarge, .systemExtraLarge:
            VStack() {
                FullDateTitleView(date: entry.date)
                CircularContainerView(currentShichen: shichen, padding: 0)
            }
        default:
            CompactShichenView(shichen: shichen, date: entry.date)
        }
    }
}


struct ShiChenEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
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
