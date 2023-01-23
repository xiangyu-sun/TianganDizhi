
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

  var components: DateComponents {
    Date().dateComponentsFromChineseCalendar()
  }
  
  var body: some View {
    
    let nian = components.nian
    let yue = components.yue
    let ri = components.riZhu
    let shi = components.shiZhu
    GeometryReader { proxy in
      ScrollView {
        LazyVGrid(columns: columns, alignment: .center, spacing: 0) {
          ForEach(data, id: \.description) { item in
            ZStack(alignment: .bottom) {
              Text("\(item.description)")
                .font(bodyFont)
              #if os(iOS)
                .frame(minHeight: proxy.size.height / 6)
              #endif

              #if os(watchOS)

              #else
              if nian == item {
                Text("年柱")
                  .font(footnote)
              }
              #endif
            }
            .foregroundColor((nian == item || yue == item || ri == item) ? .primary : .secondary)
          }
        }
      }
      .padding()
    }
    .navigationTitle("六十甲子")
  }
}

// MARK: - JiaziView_Previews

struct JiaziView_Previews: PreviewProvider {
  static var previews: some View {
    JiaziView()
  }
}
