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
import MusicTheory
import SwiftUI

// MARK: - DizhiGridView

struct DizhiGridView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.titleFont) var titleFont

  let dizhi: Dizhi

  var body: some View {
    VStack {
      HStack {
        Text(dizhi.chineseCharacter)
          .font(titleFont)
      }

      Text(dizhi.luizhu.rawValue)
        .font(bodyFont)

      HStack {
        Text(dizhi.jie.chineseName)
        Text(dizhi.qi.chineseName)
      }
      .font(bodyFont)

      HStack {
        let zodiac = Zodiac(dizhi)
        Text("\(zodiac.rawValue)")
          .font(bodyFont)

        Text(Key.shierLvLv[dizhi.rawValue - 1].lvlvDescription)
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
