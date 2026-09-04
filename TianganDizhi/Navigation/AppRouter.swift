//
//  AppRouter.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 04/09/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import SwiftUI

// MARK: - AppTab

/// The five root tabs. Raw values are reported as the `tab` / `dest` analytics
/// dimensions — they are stable identifiers, not display strings, so don't rename.
enum AppTab: String, Hashable, CaseIterable {
  case shichen
  case knowledge
  case gua
  case chart
  case settings
}

// MARK: - AppRouter

/// Owns root-level tab selection so a widget deep link can steer the UI from the
/// `App` scene, above `ContentView`.
final class AppRouter: ObservableObject {

  @Published var selectedTab = AppTab.shichen

  /// Where a tap on each widget lands. Widgets about the current time and date go
  /// to 時辰; the seasonal and almanac ones go to 天干地支, where that content lives.
  static func destination(forWidgetKind kind: String) -> AppTab {
    switch kind {
    case "ShiChen", "ShiChenByMinute", "Nongli", "CalendarWidget", "ShiChenStack":
      .shichen
    case "Jieqi", "JieqiHealth", "SpecialDay", "LuckWidget":
      .knowledge
    default:
      // Includes the countdown widget's reverse-DNS kind.
      .shichen
    }
  }
}
