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
  @Environment(\.displayLanguage) var displayLanguage

  let dizhi: Dizhi

  var body: some View {
    VStack {
      HStack {
        Text(dizhi.chineseCharacter)
          .font(titleFont)
      }

      Text(dizhi.luizhu.displayName(in: displayLanguage))
        .font(bodyFont)

      HStack {
        Text(dizhi.jie.localizedName(in: displayLanguage.glyphLanguage))
        Text(dizhi.qi.localizedName(in: displayLanguage.glyphLanguage))
      }
      .font(bodyFont)

      HStack {
        let zodiac = Zodiac(dizhi)
        Text(zodiac.localizedName(in: displayLanguage.glyphLanguage))
          .font(bodyFont)

        Text(Key.shierLvLv[dizhi.rawValue - 1].lvlvDescription.converted(to: displayLanguage))
          .font(bodyFont)
      }
    }
  }
}

#Preview {
  DizhiGridView(dizhi: .zi)
}
