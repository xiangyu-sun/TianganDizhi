//
//  ChineseMoonPhase+Toggle.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 4/1/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import Bagua
import ChineseAstrologyCalendar

extension ChineseMoonPhase {
  /// The phase's name: the classical (傳統) name or the modern one, in the
  /// script of `language`.
  func name(traditionnal: Bool, language: DisplayLanguage = .app) -> String {
    let name = traditionnal ? acientChineseName(.day8) : modernChineseName(.day8)
    return name.converted(to: language.glyphLanguage)
  }
}

extension Trigram {
  /// The symbol, name and image in the script of `language`, e.g. "☷ (坤) – 地".
  /// Names come from Bagua rather than a script transform, which turns 乾 into 干.
  func description(in language: DisplayLanguage = .app) -> String {
    let glyphs = language.glyphLanguage
    return "\(symbol) (\(localizedName(in: glyphs))) – \(localizedXiang(in: glyphs))"
  }
}
