//
//  CircularWidgetView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 26/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar
import WidgetKit

struct CircularWidgetView: View {
    
    @Environment(\.bodyFont) var bodyFont
    
    @State var date: Date
    
    var body: some View {
        let shichen = try! GanzhiDateConverter.shichen(date)
      
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
    }
}

struct CircularWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        CircularWidgetView(date: .now)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
