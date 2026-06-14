//
//  ChartListView.swift
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
  @Environment(\.footnote) var footnote
  @State private var navigationPath = NavigationPath()

  var body: some View {
    NavigationStack(path: $navigationPath) {
      List {
        Section(
          header: Text("快速查閱表"),
          footer: Text("以下為天干地支相關的快速查閱表格，適合作為參考工具。")
            .font(footnote))
        {
          NavigationLink(value: ChartRoute.twelveView) {
            Text("十二地支表")
          }
          NavigationLink(value: ChartRoute.jiaziView) {
            Text("六十甲子（含納音）")
          }
          NavigationLink(value: ChartRoute.fangwei) {
            Text("五方")
          }
        }
      }
      .font(bodyFont)
      .navigationTitle(Text("參考圖示"))
      .navigationDestination(for: ChartRoute.self) { route in
        switch route {
        case .twelveView:
          TwelveView()
        case .jiaziView:
          JiaziView()
        case .fangwei:
          FangweiView()
        }
      }
    }
  }
}

#Preview {
  ChartListView()
}
