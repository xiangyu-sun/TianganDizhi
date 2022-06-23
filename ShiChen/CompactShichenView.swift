//
//  CompactShichenView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/16/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar
import WidgetKit

struct CompactShichenView: View {
    @Environment(\.largeTitleFont) var largeTitleFont
    @Environment(\.title3Font) var title3Font
    
    let shichen: Dizhi
    let date: Date
    
    var body: some View {
        VStack() {
            titleView
            Text(shichen.displayHourText)
            .font(largeTitleFont)
            
            ShichenInformationView(shichen: shichen)
        }
    }
    
    private var titleView: some View {
        HStack(){
            Text((try? GanzhiDateConverter.nian(date).formatedYear) ?? "")
            Text((try? GanzhiDateConverter.zodiac(date).rawValue) ?? "")
        }
        .font(title3Font)
    }
}

struct CompactShichenView_Previews: PreviewProvider {
    static var previews: some View {
        CompactShichenView(shichen: .zi, date: Date())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
