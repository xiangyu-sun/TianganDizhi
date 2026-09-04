//
//  AnalyticsScreen.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 04/09/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import SwiftUI

// MARK: - AnalyticsScreen

/// A navigable destination that reports itself when shown.
///
/// The three route enums conform, so every pushed content screen is instrumented
/// at its `navigationDestination` rather than in each of the ~20 view files.
protocol AnalyticsScreen {
  /// Stable snake_case identifier reported as `screen_name`. Not a display
  /// string — renaming one breaks continuity in Google Analytics.
  var screenName: String { get }

  /// Set only by routes that carry a specific entry (a 地支, a 卦), so the
  /// lookups worth turning into widgets can be counted.
  var contentDetail: (category: String, item: String)? { get }
}

extension AnalyticsScreen {
  var contentDetail: (category: String, item: String)? { nil }
}

// MARK: - ScreenTracker

private struct ScreenTracker<Screen: AnalyticsScreen>: ViewModifier {
  let screen: Screen

  func body(content: Content) -> some View {
    content.onAppear {
      AnalyticsService.log(.screenView(name: screen.screenName))
      if let detail = screen.contentDetail {
        AnalyticsService.log(.contentDetailOpened(category: detail.category, item: detail.item))
      }
    }
  }
}

extension View {
  /// Reports a `screen_view` each time this destination appears, including on
  /// return from a deeper push — which is the behaviour a screen report wants.
  func trackScreen(_ screen: some AnalyticsScreen) -> some View {
    modifier(ScreenTracker(screen: screen))
  }
}
