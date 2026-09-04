//
//  NavigationModels.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 10/10/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//

import Bagua
import ChineseAstrologyCalendar
import Foundation
import SwiftUI

// MARK: - Knowledge Tab Routes

enum KnowledgeRoute: Hashable {
  case wuxing
  case wuyin
  case tianganList
  case dizhiDetail
  case dizhiRelationship(Dizhi)
  case shici
  case twelveGods
  case jieqiList
  case nayin
  case upcomingFestivals
  case bazi
}

// MARK: - Gua Tab Routes

enum GuaRoute: Hashable {
  case bagua(guas: [Trigram], title: String)
  case shierPigua
  case yangliShierPigua

  // Custom Hashable implementation for bagua case
  func hash(into hasher: inout Hasher) {
    switch self {
    case .bagua(let guas, let title):
      hasher.combine("bagua")
      hasher.combine(title)
      // Hash gua names instead of full objects
      for gua in guas {
        hasher.combine(gua.chineseCharacter)
      }
    case .shierPigua:
      hasher.combine("shierPigua")
    case .yangliShierPigua:
      hasher.combine("yangliShierPigua")
    }
  }

  static func == (lhs: GuaRoute, rhs: GuaRoute) -> Bool {
    switch (lhs, rhs) {
    case (.bagua(let guas1, let title1), .bagua(let guas2, let title2)):
      return title1 == title2 && guas1.map { $0.chineseCharacter } == guas2.map { $0.chineseCharacter }
    case (.shierPigua, .shierPigua):
      return true
    case (.yangliShierPigua, .yangliShierPigua):
      return true
    default:
      return false
    }
  }
}

// MARK: - Chart Tab Routes

enum ChartRoute: Hashable {
  case twelveView
  case jiaziView
  case fangwei
}

// MARK: - Analytics screen names

// Raw values are reported as the `screen_name` / `item` dimensions in Google
// Analytics. They are stable identifiers, not display strings — don't rename.

extension KnowledgeRoute: AnalyticsScreen {
  var screenName: String {
    switch self {
    case .wuxing: "wuxing_relationship"
    case .wuyin: "wuyin"
    case .tianganList: "tiangan_list"
    case .dizhiDetail: "dizhi_detail"
    case .dizhiRelationship: "dizhi_relationship"
    case .shici: "shici"
    case .twelveGods: "twelve_gods"
    case .jieqiList: "jieqi_list"
    case .nayin: "nayin"
    case .upcomingFestivals: "upcoming_festivals"
    case .bazi: "bazi"
    }
  }

  var contentDetail: (category: String, item: String)? {
    switch self {
    case .dizhiRelationship(let dizhi):
      ("dizhi", dizhi.chineseCharacter)
    default:
      nil
    }
  }
}

extension GuaRoute: AnalyticsScreen {
  var screenName: String {
    switch self {
    case .bagua: "bagua"
    case .shierPigua: "shier_pigua"
    case .yangliShierPigua: "yangli_shier_pigua"
    }
  }

  var contentDetail: (category: String, item: String)? {
    switch self {
    case .bagua(_, let title):
      ("gua", title)
    default:
      nil
    }
  }
}

extension ChartRoute: AnalyticsScreen {
  var screenName: String {
    switch self {
    case .twelveView: "twelve_chart"
    case .jiaziView: "jiazi_chart"
    case .fangwei: "fangwei_chart"
    }
  }
}
