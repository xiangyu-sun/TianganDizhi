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
    // `.task` on first appearance and `scenePhase == .active` on every
    // foregrounding both call this around the same moment on launch. Both
    // pass `shouldReportToday` before either has a chance to write the
    // throttle stamp (that write only happens at the very end, after an
    // `await`), so without this in-memory guard every widget gets counted
    // twice on the first activation of each day.
    guard !isReporting else { return }
    guard shouldReportToday else { return }
    isReporting = true
    defer { isReporting = false }

    // Widget info is unavailable (rare, transient) on failure. Leave the stored
    // snapshot untouched so tomorrow's run still diffs against real data.
    guard let widgets = await currentWidgets() else { return }

    let installed = widgets.map { Installed(info: $0) }
    let currentCounts = Dictionary(grouping: installed, by: \.id).mapValues(\.count)
    let previousCounts = storedSnapshot

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
    //
    // Diffing by *count per id* rather than set membership matters when a
    // user has two widgets of the same kind and family: deleting one used to
    // be invisible (the id was still present, so `subtracting` saw nothing
    // removed), and adding a second was equally invisible (the id was
    // already present, so membership alone couldn't tell "added").
    if let previousCounts {
      for (id, currentCount) in currentCounts {
        let previousCount = previousCounts[id] ?? 0
        if currentCount > previousCount {
          let widget = installed.first { $0.id == id } ?? Installed(id: id)
          for _ in 0..<(currentCount - previousCount) {
            log(.widgetAdded(kind: widget.kind, family: widget.family, surface: widget.surface))
          }
        }
      }
      for (id, previousCount) in previousCounts {
        let currentCount = currentCounts[id] ?? 0
        if currentCount < previousCount {
          let widget = installed.first { $0.id == id } ?? Installed(id: id)
          for _ in 0..<(previousCount - currentCount) {
            log(.widgetRemoved(kind: widget.kind, family: widget.family, surface: widget.surface))
          }
        }
      }
    }

    updateUserProperties(for: installed)

    Constants.sharedUserDefault?.set(currentCounts, forKey: Constants.analyticsWidgetSnapshot)
    Constants.sharedUserDefault?.set(Date(), forKey: Constants.analyticsWidgetSnapshotDate)
    #endif
  }

  // MARK: Private

  private static var isReporting = false

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

  private static var storedSnapshot: [String: Int]? {
    Constants.sharedUserDefault?.dictionary(forKey: Constants.analyticsWidgetSnapshot) as? [String: Int]
  }

  private static var shouldReportToday: Bool {
    guard let last = Constants.sharedUserDefault?.object(forKey: Constants.analyticsWidgetSnapshotDate) as? Date else {
      return true
    }
    return isNewDay(since: last)
  }

  /// Whether `now` falls on a different calendar day than `last`, using a
  /// fixed UTC calendar rather than `Calendar.current`. Anchoring to the
  /// device's *current* timezone meant traveling across zones could skip a
  /// day (stamp written just before midnight UTC-8, checked the next
  /// morning from UTC+9 — already "today" there) or double-report within
  /// 24h (the reverse: traveling west can fall back into "yesterday").
  static func isNewDay(since last: Date, now: Date = Date()) -> Bool {
    var utc = Calendar(identifier: .gregorian)
    utc.timeZone = TimeZone(identifier: "UTC")!
    return !utc.isDate(last, inSameDayAs: now)
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
