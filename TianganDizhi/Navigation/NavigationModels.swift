//
//  NavigationModels.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 10/10/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//

import Bagua
import Foundation
import SwiftUI

// MARK: - Knowledge Tab Routes

enum KnowledgeRoute: Hashable {
  case wuxing
  case wuyin
  case tianganList
  case dizhiList(mode: DizhiListView.DisplayMode)
  case shici
  case twelveGods
  case jieqiList
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
}
