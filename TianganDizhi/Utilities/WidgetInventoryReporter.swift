//
//  WidgetInventoryReporter.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 04/09/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import Foundation
#if os(iOS)
import Intents
import WidgetKit
#endif

// MARK: - WidgetInventoryReporter

/// Reports which widgets are installed, and what changed since yesterday.
///
/// WidgetKit exposes no impression callback, so "installed and kept" is the
/// strongest available proxy for a widget earning its place. Reading the
/// inventory from the app process keeps Firebase out of the widget extensions
/// entirely.
///
/// Runs at most once per calendar day, so `widget_active` counts distinct
/// installs per day rather than app launches.
enum WidgetInventoryReporter {

  // MARK: Internal

  static func reportIfNeeded() async {
    #if os(iOS)
    guard shouldReportToday else { return }

    // Widget info is unavailable (rare, transient) on failure. Leave the stored
    // snapshot untouched so tomorrow's run still diffs against real data.
    guard let widgets = await currentWidgets() else { return }

    let installed = widgets.map { Installed(info: $0) }
    let currentIDs = Set(installed.map(\.id))
    let previousIDs = storedSnapshot

    for widget in installed {
      log(.widgetActive(kind: widget.kind, family: widget.family, surface: widget.surface))
      if widget.isConfigurable {
        log(.widgetConfig(
          kind: widget.kind,
          customDate: widget.hasCustomDate,
          customLocation: widget.hasCustomLocation))
      }
    }

    // On the very first run there is nothing to diff against — seeding the
    // snapshot silently avoids reporting every pre-existing widget as newly added.
    if let previousIDs {
      for widget in installed where !previousIDs.contains(widget.id) {
        log(.widgetAdded(kind: widget.kind, family: widget.family, surface: widget.surface))
      }
      for id in previousIDs.subtracting(currentIDs) {
        let removed = Installed(id: id)
        log(.widgetRemoved(kind: removed.kind, family: removed.family, surface: removed.surface))
      }
    }

    updateUserProperties(for: installed)

    Constants.sharedUserDefault?.set(Array(currentIDs), forKey: Constants.analyticsWidgetSnapshot)
    Constants.sharedUserDefault?.set(Date(), forKey: Constants.analyticsWidgetSnapshotDate)
    #endif
  }

  // MARK: Private

  /// A widget identified by kind and family. `id` round-trips through
  /// UserDefaults so removals can be reported after the widget is already gone.
  private struct Installed {

    // MARK: Lifecycle

    #if os(iOS)
    init(info: WidgetInfo) {
      kind = info.kind
      family = WidgetDeepLink.name(for: info.family)
      // Only the SiriKit-intent widgets expose their configuration here. The
      // AppIntent-based ones (Calendar, Luck, JieqiHealth) report `nil`, so they
      // are marked unconfigurable rather than reported as "no custom values" —
      // that would be indistinguishable from a genuine empty configuration.
      let intent = info.configuration as? ConfigurationIntent
      isConfigurable = intent != nil
      hasCustomDate = intent?.date != nil
      hasCustomLocation = intent?.location != nil
    }
    #endif

    init(id: String) {
      let parts = id.split(separator: "|", maxSplits: 1).map(String.init)
      kind = parts.first ?? "unknown"
      family = parts.count > 1 ? parts[1] : "unknown"
      isConfigurable = false
      hasCustomDate = false
      hasCustomLocation = false
    }

    // MARK: Internal

    let kind: String
    let family: String
    var isConfigurable = false
    var hasCustomDate = false
    var hasCustomLocation = false

    var id: String { "\(kind)|\(family)" }
    var surface: String { WidgetDeepLink.surface(for: family) }
  }

  #if os(iOS)
  /// `WidgetCenter.currentConfigurations()` is iOS 18+; this wraps the
  /// completion-handler form that is available on the app's iOS 17 minimum.
  private static func currentWidgets() async -> [WidgetInfo]? {
    await withCheckedContinuation { continuation in
      WidgetCenter.shared.getCurrentConfigurations { result in
        continuation.resume(returning: try? result.get())
      }
    }
  }
  #endif

  private static var storedSnapshot: Set<String>? {
    guard let stored = Constants.sharedUserDefault?.array(forKey: Constants.analyticsWidgetSnapshot) as? [String] else {
      return nil
    }
    return Set(stored)
  }

  private static var shouldReportToday: Bool {
    guard let last = Constants.sharedUserDefault?.object(forKey: Constants.analyticsWidgetSnapshotDate) as? Date else {
      return true
    }
    return !Calendar.current.isDateInToday(last)
  }

  private static func log(_ event: AnalyticsService.Event) {
    AnalyticsService.log(event)
  }

  private static func updateUserProperties(for installed: [Installed]) {
    AnalyticsService.setUserProperty(bucket(installed.count), for: .widgetCount)
    AnalyticsService.setUserProperty(
      String(installed.contains { $0.surface == "home" }), for: .hasHomeWidget)
    AnalyticsService.setUserProperty(
      String(installed.contains { $0.surface == "lock" }), for: .hasLockWidget)

    // Most-installed kind, ties broken alphabetically so the value is stable.
    let topKind = Dictionary(grouping: installed, by: \.kind)
      .map { (kind: $0.key, count: $0.value.count) }
      .sorted { ($0.count, $1.kind) > ($1.count, $0.kind) }
      .first?.kind
    AnalyticsService.setUserProperty(topKind ?? "none", for: .topWidgetKind)
  }

  /// Bucketed to keep the dimension low-cardinality and the segments meaningful.
  private static func bucket(_ count: Int) -> String {
    switch count {
    case 0: "0"
    case 1: "1"
    case 2: "2"
    case 3...5: "3-5"
    default: "6+"
    }
  }
}
