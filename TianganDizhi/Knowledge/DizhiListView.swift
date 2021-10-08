//
//  DizhiListView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct DizhiListView: View {
    @Environment(\.bodyFont) var bodyFont
    enum DisplayMode {
        case name
        case month
        case time
        case organs
        case zodiac
        case alias
        case lvlv
        
        var dizhi: [Dizhi] {
            switch self {
            case .name:
                return Dizhi.orderedAllCases
            case .month:
                return Dizhi.xiaDynastyYearOrder
            case .time:
                return Dizhi.orderedAllCases
            case .organs:
                return Dizhi.orderedAllCases
            case .alias:
                return Dizhi.orderedAllCases
            case .zodiac:
                return Dizhi.orderedAllCases
            case .lvlv:
                return Dizhi.xiaDynastyYearOrder
            }
        }
        
        var title: String {
            switch self {
            case .name:
                return "十二地支"
            case .month:
                return "時辰與月份"
            case .time:
                return "時辰與小時"
            case .organs:
                return "時辰與經絡"
            case .alias:
                return "時辰的別名"
            case .zodiac:
                return "十二生肖"
            case .lvlv:
                return "十二律呂"
            }
        }
    }
    
    let disppayMode: DisplayMode
    
    var body: some View {
        List(disppayMode.dizhi, id: \.self) {
            switch self.disppayMode {
            case .name:
                DizhiCell(dizhi: $0)
            case .time:
                ShichenHourCell(shichen: $0)
            case .month:
                ShichenMonthCell(shichen: $0)
            case .organs:
                OrganShichenCell(shichen: $0)
            case .alias:
                AliasShichenCell(shichen: $0)
            case .zodiac:
                DizhiZodiaCell(dizhi: $0)
            case .lvlv:
                LvlvCell(dizhi: $0)
            }
        }
        .font(bodyFont)
        .navigationBarTitle(disppayMode.title)
    }
}

struct DizhiListView_Time_Previews: PreviewProvider {
    static var previews: some View {
        DizhiListView(disppayMode: .time)
            .environment(\.locale, Locale(identifier: "jp_JP"))
        DizhiListView(disppayMode: .name)
        DizhiListView(disppayMode: .month)
        DizhiListView(disppayMode: .organs)
        DizhiListView(disppayMode: .alias)
        DizhiListView(disppayMode: .zodiac)
        DizhiListView(disppayMode: .lvlv)
    }
}

