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
        Dizhi.allCases
      case .month:
        Dizhi.orderedMonthAlCases
      case .time:
        Dizhi.allCases
      case .organs:
        Dizhi.allCases
      case .alias:
        Dizhi.allCases
      case .zodiac:
        Dizhi.allCases
      case .lvlv:
        Dizhi.orderedMonthAlCases
      }
    }

    var title: String {
      switch self {
      case .name:
        "十二地支"
      case .month:
        "地支與陰曆月份"
      case .time:
        "時辰與小時"
      case .organs:
        "子午流注"
      case .alias:
        "時辰的別名"
      case .zodiac:
        "十二生肖與五行"
      case .lvlv:
        "地支，十二律呂，西洋調名"
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
//          .background($0.yin ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
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
