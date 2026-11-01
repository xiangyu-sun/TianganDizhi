//
//  DateFormatters.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 7/1/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import Foundation

extension RelativeDateTimeFormatter {

  @MainActor static let dateFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.dateTimeStyle = .numeric
    formatter.unitsStyle = .spellOut
    formatter.locale = Locale(identifier: "zh-Hant")
    return formatter
  }()

  /// The same countdown wording in the device's language ("in 3 months"), for
  /// the languages that are not Chinese.
  @MainActor static let localeDateFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.dateTimeStyle = .numeric
    formatter.unitsStyle = .full
    formatter.locale = .autoupdatingCurrent
    return formatter
  }()

  /// The countdown formatter for `language`.
  @MainActor static func countdown(for language: DisplayLanguage) -> RelativeDateTimeFormatter {
    language.isChinese ? dateFormatter : localeDateFormatter
  }

}
