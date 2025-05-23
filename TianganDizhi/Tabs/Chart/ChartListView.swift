//
//  KnowledgeView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - ChartListView

struct ChartListView: View {
  @Environment(\.bodyFont) var bodyFont

  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: TwelveView()) {
          Text("十二地支表")
        }
        NavigationLink(destination: JiaziView()) {
          Text("六十甲子")
        }
      }
      .font(bodyFont)
      .navigationTitle(Text("圖示"))
    }
  }
}

// MARK: - ChartListView_Previews

struct ChartListView_Previews: PreviewProvider {
  static var previews: some View {
    ChartListView()
  }
}
