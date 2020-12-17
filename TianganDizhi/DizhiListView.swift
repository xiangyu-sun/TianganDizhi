//
//  DizhiListView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar
import JingluoShuxue

struct DizhiListView: View {
    @Environment(\.bodyFont) var bodyFont
    enum DisplayMode {
        case name
        case month
        case time
        case organs
        case zodiac
        case alias
        
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
            }
        }
    }
    
    let dizhi = Dizhi.allCases
    let disppayMode: DisplayMode
    
    var body: some View {
        List(dizhi, id: \.self) {
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
            }
        }
        .font(bodyFont)
        .navigationBarTitle(disppayMode.title)
    }
}

struct DizhiCell: View {
    let dizhi: Dizhi

    var body: some View {
        HStack() {
            Text(dizhi.chineseCharactor)
            Text("(\(dizhi.chineseCharactor.transformToPinyin()))")
        }
        .padding()
    }
}

struct DizhiZodiaCell: View {
    let dizhi: Dizhi

    var body: some View {
        HStack() {
            Text(dizhi.chineseCharactor)
            Text("\(Zodiac(dizhi).rawValue)")
        }
        .padding()
    }
}

struct ShichenMonthCell: View {
    let shichen: Dizhi
    var body: some View {
        HStack() {
            Text(shichen.chineseCharactor)
            Spacer()
            Text(shichen.formattedMonth)
        }
        .padding()
    }
}


struct ShichenHourCell: View {
    let shichen: Dizhi
    var body: some View {
        HStack() {
            Text(shichen.chineseCharactor)
            Spacer()
            Text(shichen.formattedHourRange ?? "")
        }
        .padding()
    }
}

struct OrganShichenCell: View {
    let shichen: Dizhi

    var body: some View {
        HStack() {
            Text(shichen.chineseCharactor)
                
            Spacer()
            Text(气血循环流注[shichen.rawValue - 1].rawValue)
        }
        .padding()
    }
}

struct AliasShichenCell: View {
    let shichen: Dizhi
    var body: some View {
        HStack() {
            Text(shichen.chineseCharactor)
            Spacer()
            Text(shichen.aliasName)
        }
        .padding()
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
    }
}

