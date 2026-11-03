//
//  Constants.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 22/12/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import Foundation

enum Constants {
  static let springFestiveBackgroundEnabled = "springFestiveBackgroundEnabled"
  static let springFestiveForegroundEnabled = "springFestiveForegroundEnabled"

  static let useTranditionalNaming = "useTranditionalNaming"
  static let displayMoonPhaseOnWidgets = "displayMoonPhaseOnWidgets"

  static let piGuaRotationEnabled = "piGuaRotationEnabled"

  static let useGTM8 = "useGTM8"

  static let lastlocationKey = "lastlocationKey"
  static let useSystemFont = "useSystemFont"
  static let hasCompletedOnboarding = "hasCompletedOnboarding"
  static let backgroundStyle = "backgroundStyle"  // 0 = xuan paper, 1 = stone marble
  static let analyticsEnabled = "analyticsEnabled"
  static let analyticsWidgetSnapshot = "analyticsWidgetSnapshot"
  static let analyticsWidgetSnapshotDate = "analyticsWidgetSnapshotDate"
  /// JSON-encoded `[CustomHoliday]` — the user's 自訂節日.
  static let customHolidays = "customHolidays"
  /// The 語言 setting: a localization identifier (`AppLanguage.choices`), or
  /// absent / empty to follow the device. See `AppLanguage`.
  static let appLanguage = "appLanguage"
  /// Set once `AppLanguage` has decided whether a returning user keeps Chinese.
  static let appLanguageMigrated = "appLanguageMigrated"
  // Same identifier on every platform — the team-ID association is handled
  // by provisioning, not by the suite string. This previously carried a
  // team ID on macOS that didn't even match this project's actual
  // DEVELOPMENT_TEAM, and wasn't declared in ShichenMacWidget's
  // entitlements at all, so the Mac widget could never share this suite.
  nonisolated(unsafe) static let sharedUserDefault = UserDefaults(suiteName: "group.uriphium.tiangandizhi")
}

// MARK: - AppLanguage

/// The app's own language choice (設置 › 語言), shared by the app and its
/// widgets through the app group.
///
/// It works through `AppleLanguages` in each process's own defaults domain, the
/// key the system's per-app language setting uses, so every string, format and
/// `DisplayLanguage.app` follows it. `Bundle.main` caches its localization the
/// first time it is asked, so `applyAtLaunch()` runs from each process's `main`
/// and a change takes effect the next time the process starts.
enum AppLanguage {

  // MARK: Internal

  /// The localizations the picker offers.
  static let choices = ["zh-Hant", "zh-Hans", "en"]

  /// Applies the 語言 setting to this process. Call first thing in `main`.
  static func applyAtLaunch() {
    // The unit-test host runs in the device language; don't pin it.
    guard
      ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil,
      let shared = Constants.sharedUserDefault,
      let domain = Bundle.main.bundleIdentifier
    else { return }
    apply(
      shared: shared,
      process: .standard,
      processDomain: domain,
      localizations: Bundle.main.localizations,
      preferredLanguages: Locale.preferredLanguages)
  }

  /// `applyAtLaunch()` with its inputs passed in, for tests.
  ///
  /// 1. A per-app language set in the system's Settings since the last launch
  ///    becomes the 語言 setting, so the two never fight.
  /// 2. Once: a returning user whose device language would now show English
  ///    keeps Traditional Chinese, the only language before 2.81.0.
  /// 3. The setting is written to `AppleLanguages`, or the value this wrote
  ///    before is removed when the setting follows the device.
  static func apply(
    shared: UserDefaults,
    process: UserDefaults,
    processDomain: String,
    localizations: [String],
    preferredLanguages: [String])
  {
    let applied = process.string(forKey: appliedKey)
    let current = (process.persistentDomain(forName: processDomain)?[appleLanguagesKey] as? [String])?.first

    if current != applied {
      if let current {
        shared.set(resolve([current], localizations: localizations), forKey: Constants.appLanguage)
      } else {
        shared.removeObject(forKey: Constants.appLanguage)
      }
    }

    if !shared.bool(forKey: Constants.appLanguageMigrated) {
      shared.set(true, forKey: Constants.appLanguageMigrated)
      if
        choice(in: shared) == nil,
        isReturningUser(shared),
        !resolve(preferredLanguages, localizations: localizations).hasPrefix("zh")
      {
        shared.set("zh-Hant", forKey: Constants.appLanguage)
      }
    }

    if let choice = choice(in: shared) {
      process.set([choice], forKey: appleLanguagesKey)
      process.set(choice, forKey: appliedKey)
    } else if applied != nil {
      process.removeObject(forKey: appleLanguagesKey)
      process.removeObject(forKey: appliedKey)
    }
  }

  // MARK: Private

  private static let appleLanguagesKey = "AppleLanguages"
  /// The `AppleLanguages` value this last wrote, in the process's own defaults.
  private static let appliedKey = "appLanguageApplied"

  /// Keys only an installed, used copy of the app writes. Before 2.56 there was
  /// no onboarding, so a settings change or a widget report stands in for it.
  private static let returningUserKeys = [
    Constants.hasCompletedOnboarding,
    Constants.analyticsWidgetSnapshotDate,
    Constants.lastlocationKey,
    Constants.customHolidays,
    Constants.useGTM8,
    Constants.useSystemFont,
    Constants.backgroundStyle,
    Constants.useTranditionalNaming,
    Constants.displayMoonPhaseOnWidgets,
    Constants.springFestiveBackgroundEnabled,
    Constants.springFestiveForegroundEnabled,
  ]

  private static func choice(in shared: UserDefaults) -> String? {
    shared.string(forKey: Constants.appLanguage).flatMap { choices.contains($0) ? $0 : nil }
  }

  private static func isReturningUser(_ shared: UserDefaults) -> Bool {
    returningUserKeys.contains { shared.object(forKey: $0) != nil }
  }

  /// The localization the system would pick for `languages`.
  private static func resolve(_ languages: [String], localizations: [String]) -> String {
    Bundle.preferredLocalizations(from: localizations, forPreferences: languages).first ?? "en"
  }
}
