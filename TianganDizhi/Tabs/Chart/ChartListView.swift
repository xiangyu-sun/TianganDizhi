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
  @State private var navigationPath = NavigationPath()

  var body: some View {
    NavigationStack(path: $navigationPath) {
      List {
        NavigationLink(value: ChartRoute.twelveView) {
          Text("十二地支表")
        }
        NavigationLink(value: ChartRoute.jiaziView) {
          Text("六十甲子")
        }
      }
      .font(bodyFont)
      .navigationTitle(Text("圖示"))
      .navigationDestination(for: ChartRoute.self) { route in
        switch route {
        case .twelveView:
          TwelveView()
        case .jiaziView:
          JiaziView()
        }
      }
    }
  }
}

// MARK: - ChartListView_Previews

struct ChartListView_Previews: PreviewProvider {
  static var previews: some View {
    ChartListView()
  }
}
