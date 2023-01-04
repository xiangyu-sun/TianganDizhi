//
//  DizhiListView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - DizhiListView

struct DizhiListView: View {
  enum DisplayMode {
    case name
    case month
    case time
    case organs
    case zodiac
    case alias
    case lvlv

    // MARK: Internal

    var dizhi: [Dizhi] {
      switch self {
      case .name:
        return Dizhi.allCases
      case .month:
        return Dizhi.orderedMonthAlCases
      case .time:
        return Dizhi.allCases
      case .organs:
        return Dizhi.allCases
      case .alias:
        return Dizhi.allCases
      case .zodiac:
        return Dizhi.allCases
      case .lvlv:
        return Dizhi.orderedMonthAlCases
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
        return "子午流注"
      case .alias:
        return "時辰的別名"
      case .zodiac:
        return "十二生肖"
      case .lvlv:
        return "十二律呂"
      }
    }
  }

  @Environment(\.bodyFont) var bodyFont

  let disppayMode: DisplayMode

  var body: some View {
    List(disppayMode.dizhi, id: \.self) {
      switch disppayMode {
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
    .navigationTitle(disppayMode.title)
  }
}

// MARK: - DizhiListView_Time_Previews

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
