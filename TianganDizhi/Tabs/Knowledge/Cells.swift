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
  let dizhi: Dizhi

  var body: some View {
    HStack {
      Text(dizhi.chineseCharacter)
      Text("(\(dizhi.pinyin))")
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
      Text(dizhi.chineseCharacter)
      Text(zodiac.localizedName(in: displayLanguage.glyphLanguage))
      Spacer()
      Text(dizhi.wuxing.chineseCharacter)
    }
    .padding()
  }
}

// MARK: - ShichenMonthCell

struct ShichenMonthCell: View {
  let shichen: Dizhi
  var body: some View {
    HStack {
      Text(shichen.chineseCharacter)
      Spacer()
      Text(shichen.formattedMonth)
    }
    .padding()
  }
}

// MARK: - ShichenHourCell

struct ShichenHourCell: View {
  let shichen: Dizhi
  var body: some View {
    HStack {
      Text(shichen.chineseCharacter)
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
      Text(shichen.chineseCharacter)
      Text(shichen.formattedHourRange ?? "")
      Text(shichen.luizhu.displayName(in: displayLanguage))
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
      Text(shichen.chineseCharacter)
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
      Text(dizhi.chineseCharacter)

      Spacer()
      let value = Key.shierLvLv[dizhi.rawValue - 1]
      Text(value.lvlvDescription.converted(to: displayLanguage))
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
