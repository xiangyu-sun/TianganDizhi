
//  JiaziView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 15/10/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - JiaziView

struct JiaziView: View {

  let data = getJiazhi()
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  let columns = [
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
  ]

  // Cached at view init time — not recomputed on every body call
  let components: DateComponents = Date().dateComponentsFromChineseCalendar()
  let normalCompoenent: DateComponents = Date().dateComponentsFromCurrentCalendar

  var body: some View {
    let nian = components.nian
    let yue = components.yue
    let ri = normalCompoenent.riZhu
    let shi = normalCompoenent.shiZhu
    GeometryReader { proxy in
      ScrollView {
        LazyVGrid(columns: columns, alignment: .center, spacing: 0) {
          ForEach(data, id: \.description) { item in
            ZStack(alignment: .bottom) {
              Text("\(item.description)")
                .font(bodyFont)
              #if os(iOS) || os(macOS)
                .frame(minHeight: min(proxy.size.height / 6, 100))

              #endif

              #if os(watchOS)

              #else
              if nian == item {
                Text("年柱")
                  .font(footnote)
              }
              if yue == item {
                Text("月柱")
                  .font(footnote)
              }
              if ri == item {
                Text("日柱")
                  .font(footnote)
              }
              if shi == item {
                Text("時柱")
                  .font(footnote)
              }
              #endif
            }
            .foregroundStyle((nian == item) ? .primary : .secondary)
            .accessibilityElement(children: .combine)
            .accessibilityLabel({
              var label = item.description
              if nian == item { label += "，年柱" }
              if yue == item { label += "，月柱" }
              if ri == item { label += "，日柱" }
              if shi == item { label += "，時柱" }
              return label
            }())
          }
        }
      }
      .padding()
    }
    .navigationTitle("六十甲子")
  }
}

#Preview {
  JiaziView()
}
