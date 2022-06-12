//
//  CompactShichenView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/16/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct CompactShichenView: View {
    @Environment(\.largeTitleFont) var largeTitleFont
    @Environment(\.bodyFont) var bodyFont
    
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
                .font(bodyFont)
            Text((try? GanzhiDateConverter.zodiac(date).rawValue) ?? "")
                .font(bodyFont)
        }
    }
}

struct CompactShichenView_Previews: PreviewProvider {
    static var previews: some View {
        CompactShichenView(shichen: .zi, date: Date())
    }
}
