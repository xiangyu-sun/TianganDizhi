//
//  KnowledgeView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - KnowledgeView

struct KnowledgeView: View {
  @Environment(\.bodyFont) var bodyFont
  @State private var navigationPath = NavigationPath()

  var body: some View {
    NavigationStack(path: $navigationPath) {
      List {
        Section(header: Text("五行")) {
          NavigationLink(value: KnowledgeRoute.wuxing) {
            Text("五行以及衍生")
          }
          NavigationLink(value: KnowledgeRoute.wuyin) {
            Text("五音")
          }
        }
        Section(header: Text("十天干")) {
          NavigationLink(value: KnowledgeRoute.tianganList) {
            Text("十天干")
          }
        }
        Section(header: Text("十二地支")) {
          NavigationLink(value: KnowledgeRoute.dizhiList(mode: .name)) {
            Text(DizhiListView.DisplayMode.name.title)
          }
          NavigationLink(value: KnowledgeRoute.dizhiList(mode: .zodiac)) {
            Text(DizhiListView.DisplayMode.zodiac.title)
          }
          NavigationLink(value: KnowledgeRoute.dizhiList(mode: .time)) {
            Text(DizhiListView.DisplayMode.time.title)
          }
          NavigationLink(value: KnowledgeRoute.dizhiList(mode: .month)) {
            Text(DizhiListView.DisplayMode.month.title)
          }
          NavigationLink(value: KnowledgeRoute.dizhiList(mode: .organs)) {
            Text(DizhiListView.DisplayMode.organs.title)
          }
          NavigationLink(value: KnowledgeRoute.dizhiList(mode: .lvlv)) {
            Text(DizhiListView.DisplayMode.lvlv.title)
          }
          NavigationLink(value: KnowledgeRoute.shici) {
            Text("十二時辰頌")
          }
          NavigationLink(value: KnowledgeRoute.twelveGods) {
            Text("十二建除神")
          }
        }
        Section {
          NavigationLink(value: KnowledgeRoute.jieqiList) {
            Text("二十四節氣")
          }
        }
      }
      .font(bodyFont)
      .navigationTitle(Text("天干地支五行"))
      .navigationDestination(for: KnowledgeRoute.self) { route in
        switch route {
        case .wuxing:
          WuxingView()
        case .wuyin:
          WuyinView()
        case .tianganList:
          TianganListView()
        case .dizhiList(let mode):
          DizhiListView(disppayMode: mode)
        case .shici:
          ShiciView()
        case .twelveGods:
          TwelveGodsListView()
        case .jieqiList:
          JieqiListView()
        }
      }
    }
  }
}

// MARK: - KnowledgeView_Previews

struct KnowledgeView_Previews: PreviewProvider {
  static var previews: some View {
    KnowledgeView()
  }
}
