//
//  WidgetDeepLink.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 04/09/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import SwiftUI
import WidgetKit

// MARK: - WidgetDeepLink

/// The `tiangandizhi://widget?kind=…&family=…` contract shared by the widget
/// extensions (which emit it via `widgetURL`) and the app (which routes on it).
///
/// Both halves live here so the query keys can never drift apart.
enum WidgetDeepLink {

  // MARK: Internal

  static let scheme = "tiangandizhi"
  static let host = "widget"

  /// Reported as the `widget_family` analytics parameter. Values are stable
  /// dimensions in Google Analytics — add cases, never rename existing ones.
  static func name(for family: WidgetFamily) -> String {
    switch family {
    case .systemSmall: "systemSmall"
    case .systemMedium: "systemMedium"
    case .systemLarge: "systemLarge"
    case .systemExtraLarge: "systemExtraLarge"
    case .accessoryCircular: "accessoryCircular"
    case .accessoryRectangular: "accessoryRectangular"
    case .accessoryInline: "accessoryInline"
    case .accessoryCorner: "accessoryCorner"
    @unknown default: "unknown"
    }
  }

  /// Home Screen vs Lock Screen. StandBy renders a `systemSmall` widget and is
  /// not distinguishable from the Home Screen here, so it counts as `home`.
  /// `"unknown"` (an unrecognized/future family) intentionally does NOT
  /// match the `"accessory"` prefix check and falls to `home` — same
  /// fallback as before, just now reachable only for genuinely-unknown
  /// families rather than for `.accessoryCorner`, which is a real watchOS
  /// family this file is compiled into.
  static func surface(for familyName: String) -> String {
    familyName.hasPrefix("accessory") ? "lock" : "home"
  }

  static func url(kind: String, family: WidgetFamily) -> URL? {
    var components = URLComponents()
    components.scheme = scheme
    components.host = host
    components.queryItems = [
      URLQueryItem(name: "kind", value: kind),
      URLQueryItem(name: "family", value: name(for: family)),
    ]
    return components.url
  }

  /// Reads back a URL produced by `url(kind:family:)`. Returns nil for any other
  /// link so unrelated deep links keep their existing handling.
  static func parse(_ url: URL) -> (kind: String, family: String)? {
    guard
      url.scheme == scheme,
      url.host == host,
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let kind = components.queryItems?.first(where: { $0.name == "kind" })?.value
    else {
      return nil
    }
    let family = components.queryItems?.first(where: { $0.name == "family" })?.value ?? "unknown"
    return (kind, family)
  }
}

// MARK: - WidgetDeepLinkModifier

private struct WidgetDeepLinkModifier: ViewModifier {
  let kind: String

  @Environment(\.widgetFamily) private var family

  func body(content: Content) -> some View {
    #if os(watchOS)
    // The watch app has no analytics and no URL routing, and complications
    // already launch it on tap. Leave that behaviour untouched.
    content
    #else
    content.widgetURL(WidgetDeepLink.url(kind: kind, family: family))
    #endif
  }
}

extension View {
  /// Makes a tap on this widget open the app on the matching screen, carrying the
  /// widget's kind and family so the tap can be attributed.
  func widgetDeepLink(kind: String) -> some View {
    modifier(WidgetDeepLinkModifier(kind: kind))
  }
}
