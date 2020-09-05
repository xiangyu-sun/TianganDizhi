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
    enum DisplayMode {
        case name
        case month
        case time
        case organs
        case alias
    }
    
    let dizhi = Dizhi.allCases
    let disppayMode: DisplayMode
    
    var body: some View {
        List(dizhi, id: \.self) {
            switch self.disppayMode {
            case .name:
                Text($0.chineseCharactor)
                    .padding()
            case .time:
                ShichenHourCell(shichen: $0)
            case .month:
                ShichenMonthCell(shichen: $0)
            case .organs:
                OrganShichenCell(shichen: $0)
            case .alias:
                AliasShichenCell(shichen: $0)
            }
        }
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
        .font(.defaultBody)
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
        .font(.defaultBody)
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
        .font(.defaultBody)
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
        .font(.defaultBody)
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

