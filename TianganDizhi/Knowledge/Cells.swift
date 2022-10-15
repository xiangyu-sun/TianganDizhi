//
//  Cells.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 2021/2/8.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar
import JingluoShuxue
import ChineseTranditionalMusicCore

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
            let zodiac = Zodiac(dizhi)
            Text(zodiac.emoji)
            Text(dizhi.chineseCharactor)
            Text("\(zodiac.rawValue)")
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
            Text(shichen.formattedHourRange ?? "")
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

struct LvlvCell: View {
    let dizhi: Dizhi

    var body: some View {
        HStack() {
            Text(dizhi.chineseCharactor)
                
            Spacer()
            let value = 律呂.allCases[dizhi.rawValue - 1].rawValue
            Text(value)
            Text("(\(value.transformToPinyin()))")
        }
        .padding()
    }
}

struct Cells_Previews: PreviewProvider {
    static var previews: some View {
        LvlvCell(dizhi: .zi)
        OrganShichenCell(shichen: .zi)
    }
}
