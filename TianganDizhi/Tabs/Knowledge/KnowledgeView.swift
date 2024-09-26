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
    let _ = print("Loaded  GuaListView")
    NavigationView {
      List {
        Section(header: Text("五行")) {
          NavigationLink(destination: WuxingView()) {
            Text("五行以及衍生")
          }
          NavigationLink(destination: WuyinView()) {
            Text("五音")
          }
        }
        Section(header: Text("十天干")) {
          NavigationLink(destination: TianganListView()) {
            Text("十天干")
          }
        }
        Section(header: Text("十二地支")) {
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
          NavigationLink(destination: DizhiListView(disppayMode: .organs)) {
            Text(DizhiListView.DisplayMode.organs.title)
          }
          NavigationLink(destination: DizhiListView(disppayMode: .lvlv)) {
            Text(DizhiListView.DisplayMode.lvlv.title)
          }
          NavigationLink(destination: ShiciView()) {
            Text("十二時辰頌")
          }
        }
        Section {
          NavigationLink(destination: JieqiListView()) {
            Text("二十四節氣")
          }
        }
      }
      .font(bodyFont)
      .navigationTitle(Text("天干地支五行"))
    }
  }
}

// MARK: - KnowledgeView_Previews

struct KnowledgeView_Previews: PreviewProvider {
  static var previews: some View {
    KnowledgeView()
  }
}
