//
//  CornerView.swift
//  ShichenWatch Watch App
//
//  Created by Xiangyu Sun on 24/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI
import WidgetKit
import ChineseAstrologyCalendar

struct CornerView: View {
    @State var date: Date
    
    var body: some View {
        let shichen = try! GanzhiDateConverter.shichen(date)
        let start = date.timeIntervalSince1970 -  shichen.startDate!.timeIntervalSince1970
        
        let base = shichen.endDate!.timeIntervalSince1970 -  shichen.startDate!.timeIntervalSince1970
        ZStack() {
            AccessoryWidgetBackground()
            Text(date.chineseDate)
                .font(.largeTitle)
            
        }
        .widgetLabel{
            Gauge(value: start/base) {
                Text("")
            } currentValueLabel: {
                Text("")
            } minimumValueLabel: {
                Text(try! GanzhiDateConverter.shichen(shichen.startDate!).displayHourText)
            } maximumValueLabel: {
                Text(shichen.next.displayHourText)
            }

        }
    }
}

struct CornerView_Previews: PreviewProvider {
    static var previews: some View {
        CornerView(date: .now)
            .previewContext(WidgetPreviewContext(family: .accessoryCorner))
    }
}
