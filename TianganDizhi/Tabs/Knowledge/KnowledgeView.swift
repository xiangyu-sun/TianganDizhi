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

  var body: some View {
    NavigationView {
      List {
        Section(header: Text("天干地支")) {
          NavigationLink(destination: TianganListView()) {
            Text("十天干")
          }
          NavigationLink(destination: DizhiListView(disppayMode: .name)) {
            Text(DizhiListView.DisplayMode.name.title)
          }
          NavigationLink(destination: DizhiListView(disppayMode: .zodiac)) {
            Text(DizhiListView.DisplayMode.zodiac.title)
          }
          NavigationLink(destination: DizhiListView(disppayMode: .time)) {
            Text(DizhiListView.DisplayMode.time.title)
          }
          NavigationLink(destination: DizhiListView(disppayMode: .month)) {
            Text(DizhiListView.DisplayMode.month.title)
          }
          NavigationLink(destination: JieqiListView()) {
            Text("二十四節氣")
          }
          NavigationLink(destination: DizhiListView(disppayMode: .organs)) {
            Text(DizhiListView.DisplayMode.organs.title)
          }
          NavigationLink(destination: DizhiListView(disppayMode: .lvlv)) {
            Text(DizhiListView.DisplayMode.lvlv.title)
          }
        }
        Section(header: Text("五行")) {
          NavigationLink(destination: WuxingView()) {
            Text("五行")
          }
        }
        Section(header: Text("詩詞歌賦頌")) {
          NavigationLink(destination: ShiciView()) {
            Text("十二時辰頌")
          }
        }
      }
      .font(bodyFont)
      .navigationTitle(Text("天干地支相關知識"))
    }
#if os(iOS) || os(watchOS)
    .navigationViewStyle(StackNavigationViewStyle())
#endif
  }
}

// MARK: - KnowledgeView_Previews

struct KnowledgeView_Previews: PreviewProvider {
  static var previews: some View {
    KnowledgeView()
  }
}
