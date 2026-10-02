//
//  Environment.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 22/10/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import CoreText
import os
import SwiftUI

extension String {
  static let weibeiBold = "Weibei TC Bold"
}

// MARK: - WeibeiFont

/// Weibei TC is licensed to Apple, so it can't ship in the bundle (ITMS-91198,
/// TN3214). The OS offers it as a downloadable system font instead: `activate()`
/// downloads it once per device and registers it once per process — the app and
/// every widget extension must each call it before rendering with it.
enum WeibeiFont {
  static let postScriptName = "WeibeiTC-Bold"

  /// Whether the font is registered in this process. CoreText substitutes a
  /// fallback for a name it can't find, so compare the name it resolved to.
  static var isAvailable: Bool {
    let font = CTFontCreateWithName(postScriptName as CFString, 12, nil)
    return CTFontCopyPostScriptName(font) as String == postScriptName
  }

  /// Downloads (if needed) and registers the font, then reports whether it is
  /// now available. Gives up waiting after `timeout`; a download still in flight
  /// keeps going and is picked up by the next render.
  static func activate(timeout: TimeInterval = 10, completion: @escaping (Bool) -> Void) {
    if isAvailable {
      completion(true)
      return
    }
    // Called exactly once, from whichever of the two queues below gets there first.
    nonisolated(unsafe) let completion = completion
    let resumed = OSAllocatedUnfairLock(initialState: false)
    let finish: @Sendable () -> Void = {
      let isFirst = resumed.withLock { done in
        defer { done = true }
        return !done
      }
      if isFirst { completion(isAvailable) }
    }
    DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: finish)
    let descriptor = CTFontDescriptorCreateWithNameAndSize(postScriptName as CFString, 0)
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler([descriptor] as CFArray, nil) { state, _ in
      if state == .didFinish { finish() }
      return true
    }
  }

  @discardableResult
  static func activate(timeout: TimeInterval = 10) async -> Bool {
    await withCheckedContinuation { continuation in
      activate(timeout: timeout) { continuation.resume(returning: $0) }
    }
  }
}

extension Font {
  /// Until Weibei is activated, the bold system style — the same font the
  /// "use system font" setting picks. (`.custom` with a missing font falls back
  /// to a *regular*-weight system font at a fixed size.)
  private static func weiBei(size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
    WeibeiFont.isAvailable ? .custom(.weibeiBold, size: size, relativeTo: style) : .system(style).bold()
  }

  static var weiBeiLargeTitle: Font { weiBei(size: 50, relativeTo: .largeTitle) }
  static var weiBeiTitle: Font { weiBei(size: 40, relativeTo: .title) }
  static var weiBeiTitle2: Font { weiBei(size: 30, relativeTo: .title2) }
  static var weiBeiTitle3: Font { weiBei(size: 24, relativeTo: .title3) }
  static var weiBeiBody: Font { weiBei(size: 22, relativeTo: .body) }
  static var weiBeiCallOut: Font { weiBei(size: 18, relativeTo: .callout) }
  static var weiBeiHeadline: Font { weiBei(size: 20, relativeTo: .headline) }
  static var weiBeiFootNote: Font { weiBei(size: 12, relativeTo: .footnote) }

  static var weiBeiTitleWatch: Font { weiBei(size: 28, relativeTo: .title) }
}

extension EnvironmentValues {
  #if os(watchOS)
  @Entry var titleFont: Font = .weiBeiTitleWatch
  #else
  @Entry var titleFont: Font = .weiBeiTitle
  #endif
  @Entry var largeTitleFont: Font = .weiBeiLargeTitle
  @Entry var title2Font: Font = .weiBeiTitle2
  @Entry var title3Font: Font = .weiBeiTitle3
  @Entry var bodyFont: Font = .weiBeiBody
  @Entry var calloutFont: Font = .weiBeiCallOut
  @Entry var headlineFont: Font = .weiBeiHeadline
  @Entry var footnote: Font = .weiBeiFootNote
  /// Whether layouts should use their larger, iPad-sized variants. Nothing
  /// reads a meaningful default — each root sets it: `ContentView` from its size
  /// class and width, and the widget views from `Bool.widgetShouldScaleFont`.
  @Entry var shouldScaleFont: Bool = false
}

extension Bool {
  /// Widgets have no useful size class, so they scale up on iPad — the same
  /// devices the old `UIScreen.main.bounds.width > 744` default picked out.
  static var widgetShouldScaleFont: Bool {
    #if os(iOS)
    UIDevice.current.userInterfaceIdiom == .pad
    #else
    false
    #endif
  }
}
