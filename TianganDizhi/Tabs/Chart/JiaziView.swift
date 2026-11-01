
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
  @Environment(\.displayLanguage) var displayLanguage
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
              VStack(spacing: 2) {
                Text("\(item.description)")
                  .font(bodyFont)
                Text(item.nayin.localizedName(in: displayLanguage.glyphLanguage))
                  .font(footnote)
                  .foregroundStyle(.secondary)
              }
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
              var label = displayLanguage.isChinese ? item.description : GlossedText.accessibilityText(glyph: item.description, gloss: item.gloss(in: displayLanguage))
              if nian == item { label = String(localized: "\(label)，年柱", comment: "Accessibility: a 干支 marked as the year pillar") }
              if yue == item { label = String(localized: "\(label)，月柱", comment: "Accessibility: a 干支 marked as the month pillar") }
              if ri == item { label = String(localized: "\(label)，日柱", comment: "Accessibility: a 干支 marked as the day pillar") }
              if shi == item { label = String(localized: "\(label)，時柱", comment: "Accessibility: a 干支 marked as the hour pillar") }
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
