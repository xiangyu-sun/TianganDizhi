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
      
      let start = self.date.timeIntervalSince1970 -  shichen.startDate!.timeIntervalSince1970
      
      let base = shichen.endDate!.timeIntervalSince1970 -  shichen.startDate!.timeIntervalSince1970
   
      ProgressView(value: start/base,
                     label: {
            Text(shichen.displayHourText)
                .widgetAccentable()
        }, currentValueLabel: {
          Text(shichen.displayHourText)
              .widgetAccentable()
#if os(iOS)
              .font(bodyFont)
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
