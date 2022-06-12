//
//  ShichenView.swift
//  Shichen WatchKit Extension
//
//  Created by 孙翔宇 on 10/17/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar
import ClockKit

struct ShichenView: View {
    @State var date: Date = .init()
    @Environment(\.title3Font) var title3Font
    
    var body: some View {
        let shichen = try! GanzhiDateConverter.shichen(date)
        
        Text(shichen.chineseCharactor)
            .font(title3Font)
            .complicationForeground()
    }
}

struct ComplicationShichenView: View {
    var body: some View {
        ShichenView()
    }
}

final class ChiChenTextProvider: CLKTextProvider {
    
}

struct ShichenView_Previews: PreviewProvider {
    static var previews: some View {
        Group() {
            ShichenView()
            
            CLKComplicationTemplateGraphicCircularView(ComplicationShichenView())
                .previewContext(faceColor: .multicolor)
            
            CLKComplicationTemplateGraphicCircularView(ComplicationShichenView())
                .previewContext(faceColor: .blue)
            
        }
    }
}
