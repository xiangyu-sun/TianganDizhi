  //
//  ShichenWatch.swift
//  ShichenWatch
//
//  Created by Xiangyu Sun on 24/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents


struct ShiChen: Widget {
    let kind: String = "ShiChen"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            ShiChenEntryView(entry: entry)
        }
        .configurationDisplayName("十二时辰")
        .description("十二地支为名的十二时辰计，俗稱，以及相關臟器")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular])
        
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
                .previewDisplayName("ShiChenEntryView Inline")
            
            ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("ShiChenEntryView Circular")
            
            ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("ShiChenEntryView Retangular")
        }
    }
}