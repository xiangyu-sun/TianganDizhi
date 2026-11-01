//
//  Cells.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 2021/2/8.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import ChineseTranditionalMusicCore
import JingluoShuxue
import MusicTheory
import SwiftUI

// MARK: - Meridian display name

extension 十二经脉 {
  /// The meridian's name as the app shows it: the library's own (script-mixed)
  /// spelling, which is what Traditional Chinese and other locales have always
  /// seen, or a consistently Simplified name for Simplified Chinese.
  func displayName(in language: DisplayLanguage) -> String {
    language.glyphLanguage == .zhHans ? localizedName(in: .zhHans) : rawValue
  }
}

// MARK: - DizhiCell

struct DizhiCell: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let dizhi: Dizhi

  var body: some View {
    HStack {
      GlossedText(glyph: dizhi.chineseCharacter, gloss: dizhi.gloss(in: displayLanguage))
      // The gloss already carries the pinyin outside Chinese.
      if displayLanguage.isChinese {
        Text("(\(dizhi.pinyin))")
      }
    }
    .padding()
  }
}

// MARK: - DizhiZodiaCell

struct DizhiZodiaCell: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let dizhi: Dizhi

  var body: some View {
    HStack {
      let zodiac = Zodiac(dizhi)
      Text(zodiac.emoji)
      GlossedText(glyph: dizhi.chineseCharacter, gloss: dizhi.localizedName(in: displayLanguage))
      GlossedText(glyph: zodiac.localizedName(in: displayLanguage.glyphLanguage), gloss: zodiac.localizedName(in: displayLanguage))
      Spacer()
      GlossedText(glyph: dizhi.wuxing.chineseCharacter, gloss: dizhi.wuxing.gloss(in: displayLanguage), alignment: .trailing)
    }
    .padding()
  }
}

// MARK: - ShichenMonthCell

struct ShichenMonthCell: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let shichen: Dizhi
  var body: some View {
    HStack {
      GlossedText(glyph: shichen.chineseCharacter, gloss: shichen.gloss(in: displayLanguage))
      Spacer()
      Text(shichen.formattedMonth)
    }
    .padding()
  }
}

// MARK: - ShichenHourCell

struct ShichenHourCell: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let shichen: Dizhi
  var body: some View {
    HStack {
      GlossedText(glyph: shichen.chineseCharacter, gloss: shichen.gloss(in: displayLanguage))
      Spacer()
      Text(shichen.formattedHourRange ?? "")
    }
    .padding()
  }
}

// MARK: - OrganShichenCell

struct OrganShichenCell: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let shichen: Dizhi

  var body: some View {
    HStack {
      GlossedText(glyph: shichen.chineseCharacter, gloss: shichen.gloss(in: displayLanguage))
      Text(shichen.formattedHourRange ?? "")
        .lineLimit(1)
        .minimumScaleFactor(0.7)
      if !displayLanguage.isChinese { Spacer(minLength: 0) }
      GlossedText(
        glyph: shichen.luizhu.displayName(in: displayLanguage),
        gloss: displayLanguage.isChinese ? "" : shichen.luizhu.localizedName(in: displayLanguage),
        alignment: .trailing)
    }
    .padding()
  }
}

// MARK: - AliasShichenCell

struct AliasShichenCell: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let shichen: Dizhi
  var body: some View {
    HStack {
      GlossedText(glyph: shichen.chineseCharacter, gloss: shichen.gloss(in: displayLanguage))
      Spacer()
      Text(shichen.aliasName.converted(to: displayLanguage))
    }
    .padding()
  }
}

// MARK: - LvlvCell

struct LvlvCell: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let dizhi: Dizhi

  var body: some View {
    HStack {
      GlossedText(glyph: dizhi.chineseCharacter, gloss: dizhi.gloss(in: displayLanguage))

      Spacer()
      let value = Key.shierLvLv[dizhi.rawValue - 1]
      Text(value.localizedLvlvName(in: displayLanguage.glyphLanguage))
      Text(value.description)
      Text("(\(value.lvlvDescription.transformToPinyin()))")
    }
    .padding()
  }
}

#Preview {
  LvlvCell(dizhi: .zi)
}

#Preview {
  OrganShichenCell(shichen: .zi)
}

#Preview {
  DizhiZodiaCell(dizhi: .hai)
}

#Preview {
  ShichenMonthCell(shichen: .chen)
}
