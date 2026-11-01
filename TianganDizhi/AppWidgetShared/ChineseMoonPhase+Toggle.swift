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
  /// The phase's name: the classical (傳統) name or the modern one. Chinese
  /// languages get it in their script; outside Chinese the modern name is
  /// English ("Full Moon"), while the classical name (朔, 望 …) stays Chinese
  /// because it is the term the setting asks for.
  func name(traditionnal: Bool, language: DisplayLanguage = .app) -> String {
    if !language.isChinese && !traditionnal {
      return localizedName(in: language)
    }
    let name = traditionnal ? acientChineseName(.day8) : modernChineseName(.day8)
    return name.converted(to: language.glyphLanguage)
  }
}

extension Trigram {
  /// The symbol, name and image in `language`, e.g. "☷ (坤) – 地" or
  /// "☷ (Kun) – Earth". Names come from Bagua rather than a script transform,
  /// which turns 乾 into 干.
  func description(in language: DisplayLanguage = .app) -> String {
    "\(symbol) (\(localizedName(in: language))) – \(localizedXiang(in: language))"
  }
}
