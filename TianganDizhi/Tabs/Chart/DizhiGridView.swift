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
        GlossedText(glyph: dizhi.chineseCharacter, gloss: dizhi.localizedName(in: displayLanguage), alignment: .center)
          .font(titleFont)
      }

      GlossedText(
        glyph: dizhi.luizhu.displayName(in: displayLanguage),
        gloss: displayLanguage.isChinese ? "" : dizhi.luizhu.localizedName(in: displayLanguage),
        alignment: .center)
        .multilineTextAlignment(.center)
        .font(bodyFont)

      HStack {
        GlossedText(glyph: dizhi.jie.localizedName(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : dizhi.jie.localizedName(in: displayLanguage), alignment: .center)
        GlossedText(glyph: dizhi.qi.localizedName(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : dizhi.qi.localizedName(in: displayLanguage), alignment: .center)
      }
      .multilineTextAlignment(.center)
      .font(bodyFont)

      HStack {
        let zodiac = Zodiac(dizhi)
        GlossedText(glyph: zodiac.localizedName(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : zodiac.localizedName(in: displayLanguage), alignment: .center)
          .font(bodyFont)

        Text(Key.shierLvLv[dizhi.rawValue - 1].localizedLvlvName(in: displayLanguage.glyphLanguage))
          .font(bodyFont)
      }
    }
  }
}

#Preview {
  DizhiGridView(dizhi: .zi)
}
