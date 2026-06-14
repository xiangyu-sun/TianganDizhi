//
//  DizhiDetailView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 14/06/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - DizhiDetailView

struct DizhiDetailView: View {
  @State private var mode: DizhiListView.DisplayMode = .name

  private static let modes: [DizhiListView.DisplayMode] = [
    .name, .zodiac, .time, .month, .organs, .lvlv, .relationships,
  ]

  var body: some View {
    DizhiListView(disppayMode: mode)
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Picker("模式", selection: $mode) {
            ForEach(Self.modes, id: \.self) { m in
              Text(m.title).tag(m)
            }
          }
          .pickerStyle(.menu)
        }
      }
  }
}

#Preview {
  NavigationStack {
    DizhiDetailView()
  }
}
