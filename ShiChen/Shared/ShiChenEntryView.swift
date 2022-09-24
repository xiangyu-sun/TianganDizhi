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
    @Environment(\.title3Font) var title3Font
    
    var body: some View {
        let shichen = try! GanzhiDateConverter.shichen(entry.date)
        
        switch family {
        case .accessoryInline:
            ViewThatFits() {
                InlineWidgetView(date: entry.date)
                // ipad os
                HStack() {
                    Text(entry.date.displayStringOfChineseYearMonthDateWithZodiac)
                    Text(shichen.displayHourText)
                }
                .font(.custom("Weibei TC Bold", size: 20, relativeTo: .body))
            }
        case .accessoryCircular:
            CircularWidgetView(date: entry.date)
        case .accessoryRectangular:
            RetangularWidgetView(date: entry.date)
        case .systemMedium:
            VStack() {
                FullDateTitleView(date: entry.date)
                .font(title3Font)
                ShichenHStackView(shichen: shichen)
                    .padding([.leading, .trailing], 8)
            }
        case .systemLarge:
            VStack() {
                FullDateTitleView(date: entry.date)
                .font(title3Font)
                .padding(.top, 8)
                CircularContainerView(currentShichen: shichen, padding: -30)
                .padding(.bottom, 8)
            }
        case .systemExtraLarge:
            HStack() {
              VStack() {
                  FullDateTitleView(date: entry.date)
                  .font(titleFont)
                  Spacer()
                  ShichenHStackView(shichen: shichen)
                  Spacer()
              }
              .padding()
                CircularContainerView(currentShichen: shichen, padding: -30)
                .padding()
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
