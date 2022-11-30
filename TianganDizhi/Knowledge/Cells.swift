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
import SwiftUI

// MARK: - DizhiCell

struct DizhiCell: View {
  let dizhi: Dizhi

  var body: some View {
    HStack {
      Text(dizhi.chineseCharactor)
      Text("(\(dizhi.chineseCharactor.transformToPinyin()))")
    }
    .padding()
  }
}

// MARK: - DizhiZodiaCell

struct DizhiZodiaCell: View {
  let dizhi: Dizhi

  var body: some View {
    HStack {
      let zodiac = Zodiac(dizhi)
      Text(zodiac.emoji)
      Text(dizhi.chineseCharactor)
      Text("\(zodiac.rawValue)")
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
      Text(shichen.chineseCharactor)
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
      Text(shichen.chineseCharactor)
      Spacer()
      Text(shichen.formattedHourRange ?? "")
    }
    .padding()
  }
}

// MARK: - OrganShichenCell

struct OrganShichenCell: View {
  let shichen: Dizhi

  var body: some View {
    HStack {
      Text(shichen.chineseCharactor)
      Text(shichen.formattedHourRange ?? "")
      Text(气血循环流注[shichen.rawValue - 1].rawValue)
    }
    .padding()
  }
}

// MARK: - AliasShichenCell

struct AliasShichenCell: View {
  let shichen: Dizhi
  var body: some View {
    HStack {
      Text(shichen.chineseCharactor)
      Spacer()
      Text(shichen.aliasName)
    }
    .padding()
  }
}

// MARK: - LvlvCell

struct LvlvCell: View {
  let dizhi: Dizhi

  var body: some View {
    HStack {
      Text(dizhi.chineseCharactor)

      Spacer()
      let value = 律呂.allCases[dizhi.rawValue - 1].rawValue
      Text(value)
      Text("(\(value.transformToPinyin()))")
    }
    .padding()
  }
}

// MARK: - Cells_Previews

struct Cells_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      LvlvCell(dizhi: .zi)
      OrganShichenCell(shichen: .zi)
      DizhiZodiaCell(dizhi: .hai)
    }
  }
}
