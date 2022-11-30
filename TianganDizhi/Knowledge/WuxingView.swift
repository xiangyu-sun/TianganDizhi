//
//  WuxingView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 18/11/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - WuxingView

struct WuxingView: View {

  let columns = [
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
  ]

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, alignment: .center, spacing: 0) {
        ForEach(Wuxing.allCases, id: \.self) { item in
          Text("\(item.chineseCharacter)")
        }
      }
      .padding()
    }
  }
}

// MARK: - WuxingView_Previews

struct WuxingView_Previews: PreviewProvider {
  static var previews: some View {
    WuxingView()
  }
}
