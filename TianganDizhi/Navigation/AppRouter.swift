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
    // The kind string has a shipped typo ("tinagandizhi") that can't be
    // renamed without orphaning already-placed widgets, but the countdown
    // it displays is a 節氣 countdown — that content lives in 天干地支
    // (.knowledge), not 時辰.
    case "Jieqi", "JieqiHealth", "SpecialDay", "LuckWidget", "com.uriphium.tinagandizhi.countdown.widget":
      .knowledge
    default:
      .shichen
    }
  }
}
