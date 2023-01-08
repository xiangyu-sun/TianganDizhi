//
//  DateFormatters.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 7/1/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import Foundation

extension RelativeDateTimeFormatter {

  static let dateFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.dateTimeStyle = .numeric
    formatter.unitsStyle = .spellOut
    formatter.locale = Locale.current
    return formatter
  }()

}
