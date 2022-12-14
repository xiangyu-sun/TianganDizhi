//
//  DizhiGridView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 15/10/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import ChineseTranditionalMusicCore
import JingluoShuxue
import SwiftUI

// MARK: - DizhiGridView

struct DizhiGridView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.titleFont) var titleFont
  let dizhi: Dizhi

  var body: some View {
    VStack {
      HStack {
        Text(dizhi.chineseCharactor)
          .font(titleFont)
      }

      HStack {
        if #available(iOS 16.0, watchOS 9.0, *) {
          Text(气血循环流注[dizhi.rawValue - 1].rawValue)
            .lineLimit(2, reservesSpace: true)
        } else {
          Text(气血循环流注[dizhi.rawValue - 1].rawValue)
        }
      }
      .font(bodyFont)
      HStack {
        let zodiac = Zodiac(dizhi)
        Text("\(zodiac.rawValue)")
          .font(bodyFont)

        Text(律呂.allCases[dizhi.rawValue - 1].rawValue)
          .font(bodyFont)
      }
    }
  }
}

// MARK: - DizhiGridView_Previews

struct DizhiGridView_Previews: PreviewProvider {
  static var previews: some View {
    DizhiGridView(dizhi: .zi)
  }
}
