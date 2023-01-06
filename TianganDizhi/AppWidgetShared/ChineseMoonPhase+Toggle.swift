//
//  ChineseMoonPhase+Toggle.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 4/1/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar

extension ChineseMoonPhase {
  func name(traditionnal: Bool) -> String {
    traditionnal ? acientChineseName(.chuba) : modernChineseName(.chuba)
  }
}
