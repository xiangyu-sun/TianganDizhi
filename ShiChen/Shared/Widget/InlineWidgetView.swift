//
//  InlineWidgetView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 26/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct InlineWidgetView: View {
    
    @Environment(\.bodyFont) var bodyFont
    
    @State var date: Date
    
    var body: some View {
        let shichen = try! GanzhiDateConverter.shichen(date)
        
        ViewThatFits(in: .horizontal) {
            Text("\(date.displayStringOfChineseYearMonthDateWithZodiac) \(shichen.displayHourText)")
            Text(shichen.displayHourText)
        }
        .font(bodyFont)
        .widgetAccentable()
    }
}

@available(iOSApplicationExtension 16.0, *)
struct InlineWidgetView_Previews: PreviewProvider {
    static var previews: some View {
#if os(macOS)
        InlineWidgetView(date: .now)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
#else
        InlineWidgetView(date: .now)
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
#endif
        
        
    }
}
