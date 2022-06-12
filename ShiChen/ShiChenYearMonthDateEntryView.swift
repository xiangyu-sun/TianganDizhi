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
    @Environment(\.widgetFamily) var family
    
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
            ProgressView(interval: Date()...Date() + 60 * 60,
                         countdown: false,
                         label: { Text("時辰") },
                         currentValueLabel: {
                Text(shichen.displayHourText)
                    .font(titleFont)
                    .widgetAccentable()
            })
            .progressViewStyle(.circular)
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
