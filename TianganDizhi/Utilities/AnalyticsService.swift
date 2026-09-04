//
//  AnalyticsService.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 04/09/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import Foundation

#if os(iOS)
import FirebaseAnalytics
import FirebaseCore
#endif

// MARK: - AnalyticsService

/// Thin wrapper over Firebase Analytics.
///
/// Firebase is linked into the iOS build only — the macOS app ships from the same
/// target but is not registered as a Firebase app, so every entry point here is a
/// no-op off iOS. Call sites never import Firebase directly.
enum AnalyticsService {

  // MARK: Internal

  /// Boots Firebase and applies the user's stored collection preference.
  /// Must run once, on the main thread, before any event is logged.
  static func configure() {
    #if os(iOS)
    guard FirebaseApp.app() == nil else { return }
    guard Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil else {
      // No config bundled (e.g. a fork or a CI build without secrets) — stay silent
      // rather than trapping inside FirebaseApp.configure().
      return
    }
    FirebaseApp.configure()
    setCollectionEnabled(isCollectionEnabled)
    #endif
  }

  /// Turns collection on or off and remembers the choice.
  static func setCollectionEnabled(_ enabled: Bool) {
    Constants.sharedUserDefault?.set(enabled, forKey: Constants.analyticsEnabled)
    #if os(iOS)
    Analytics.setAnalyticsCollectionEnabled(enabled)
    #endif
  }

  /// Sets a user-scoped dimension. Firebase allows 25 of these per project; they
  /// are what lets every other metric be sliced by widget adoption.
  static func setUserProperty(_ value: String?, for property: UserProperty) {
    #if os(iOS)
    guard isCollectionEnabled else { return }
    Analytics.setUserProperty(value, forName: property.rawValue)
    #endif
  }

  static func log(_ event: Event) {
    #if os(iOS)
    guard isCollectionEnabled else { return }
    Analytics.logEvent(event.name, parameters: event.parameters)
    #endif
  }

  // MARK: Private

  /// Defaults to `true` — collection is opt-out, mirroring the Settings toggle.
  private static var isCollectionEnabled: Bool {
    Constants.sharedUserDefault?.object(forKey: Constants.analyticsEnabled) as? Bool ?? true
  }
}

// MARK: AnalyticsService.Event

extension AnalyticsService {

  /// The events this app reports. Names stay snake_case, under 40 characters, and
  /// avoid the `firebase_`/`google_`/`ga_` prefixes Firebase reserves.
  enum Event {
    case tabSelected(String)
    case onboardingCompleted
    case settingChanged(name: String, value: String)
    case deepLinkOpened(host: String)
    /// One per installed widget, at most once a day. The denominator for every
    /// other widget metric.
    case widgetActive(kind: String, family: String, surface: String)
    case widgetAdded(kind: String, family: String, surface: String)
    /// The kill-or-fix signal: which widgets users try, then delete.
    case widgetRemoved(kind: String, family: String, surface: String)
    /// Whether the `date`/`location` intent parameters are actually used.
    case widgetConfig(kind: String, customDate: Bool, customLocation: Bool)
    case widgetTapped(kind: String, family: String, destination: String)

    // MARK: Internal

    var name: String {
      switch self {
      case .tabSelected: "tab_selected"
      case .onboardingCompleted: "onboarding_completed"
      case .settingChanged: "setting_changed"
      case .deepLinkOpened: "deep_link_opened"
      case .widgetActive: "widget_active"
      case .widgetAdded: "widget_added"
      case .widgetRemoved: "widget_removed"
      case .widgetConfig: "widget_config"
      case .widgetTapped: "widget_tapped"
      }
    }

    var parameters: [String: Any]? {
      switch self {
      case .tabSelected(let tab):
        ["tab": tab]
      case .onboardingCompleted:
        nil
      case .settingChanged(let name, let value):
        ["setting_name": name, "setting_value": value]
      case .deepLinkOpened(let host):
        ["host": host]
      case .widgetActive(let kind, let family, let surface),
           .widgetAdded(let kind, let family, let surface),
           .widgetRemoved(let kind, let family, let surface):
        ["widget_kind": kind, "widget_family": family, "widget_surface": surface]
      case .widgetConfig(let kind, let customDate, let customLocation):
        ["widget_kind": kind, "custom_date": customDate, "custom_location": customLocation]
      case .widgetTapped(let kind, let family, let destination):
        ["widget_kind": kind, "widget_family": family, "dest": destination]
      }
    }
  }
}

// MARK: AnalyticsService.UserProperty

extension AnalyticsService {

  /// User-scoped dimensions. Register these in the Google Analytics console or
  /// they won't appear in any report.
  enum UserProperty: String {
    /// Bucketed rather than exact, to keep the dimension low-cardinality.
    case widgetCount = "widget_count"
    case hasHomeWidget = "has_home_widget"
    case hasLockWidget = "has_lock_widget"
    case topWidgetKind = "top_widget_kind"
  }
}
