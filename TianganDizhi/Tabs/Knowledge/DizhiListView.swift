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
    case relationships

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
      case .relationships:
        Dizhi.allCases
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
      case .relationships:
        "地支沖合害"
      }
    }
  }

  @Environment(\.bodyFont) var bodyFont
  @State private var searchText = ""

  let disppayMode: DisplayMode

  private var filteredDizhi: [Dizhi] {
    guard !searchText.isEmpty else { return disppayMode.dizhi }
    return disppayMode.dizhi.filter { dz in
      dz.chineseCharacter.localizedStandardContains(searchText) ||
      dz.aliasName.localizedStandardContains(searchText)
    }
  }

  var body: some View {
    List(filteredDizhi, id: \.self) { dz in
      switch disppayMode {
      case .name:
        DizhiCell(dizhi: dz)
      case .time:
        ShichenHourCell(shichen: dz)
      case .month:
        ShichenMonthCell(shichen: dz)
      case .organs:
        OrganShichenCell(shichen: dz)
      case .alias:
        AliasShichenCell(shichen: dz)
      case .zodiac:
        DizhiZodiaCell(dizhi: dz)
      case .lvlv:
        LvlvCell(dizhi: dz)
      case .relationships:
        NavigationLink(value: KnowledgeRoute.dizhiRelationship(dz)) {
          HStack {
            Text(dz.chineseCharacter)
            Spacer()
            Text("冲\(dz.chong.chineseCharacter)")
              .foregroundStyle(.secondary)
          }
          .padding(.vertical, 4)
        }
      }
    }
    .overlay {
      if filteredDizhi.isEmpty {
        VStack(spacing: 8) {
          Image(systemName: "magnifyingglass")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
          Text("無結果")
            .foregroundStyle(.secondary)
        }
      }
    }
    .searchable(text: $searchText)
    .font(bodyFont)
    .navigationTitle(disppayMode.title)
  }
}

#Preview {
  DizhiListView(disppayMode: .time)
    .environment(\.locale, Locale(identifier: "jp_JP"))
}

#Preview {
  DizhiListView(disppayMode: .name)
}

#Preview {
  DizhiListView(disppayMode: .month)
}

#Preview {
  DizhiListView(disppayMode: .organs)
}

#Preview {
  DizhiListView(disppayMode: .alias)
}

#Preview {
  DizhiListView(disppayMode: .zodiac)
}

#Preview {
  DizhiListView(disppayMode: .lvlv)
}
