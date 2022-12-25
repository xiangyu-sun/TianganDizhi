
//  JiaziView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 15/10/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - TwelveView

struct JiaziView: View {

  let data = getJiazhi()
    @Environment(\.bodyFont) var bodyFont
    @Environment(\.titleFont) var titleFont
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
    GridItem(.flexible(), spacing: 0)
  ]

    var body: some View {
        let nian = Date().nian
        
        GeometryReader { proxy in
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 0) {
                    ForEach(data, id: \.description) { item in
                        Text("\(item.description)")
                            .font(bodyFont)
                            .foregroundColor(nian == item ? .primary : .secondary)
                            .frame(minHeight: proxy.size.height / 6)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("六十甲子")
    }
}

// MARK: - TwelveView_Previews

struct JiaziView_Previews: PreviewProvider {
  static var previews: some View {
      JiaziView()
  }
}
