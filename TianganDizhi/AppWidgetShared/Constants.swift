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
  // Same identifier on every platform — the team-ID association is handled
  // by provisioning, not by the suite string. This previously carried a
  // team ID on macOS that didn't even match this project's actual
  // DEVELOPMENT_TEAM, and wasn't declared in ShichenMacWidget's
  // entitlements at all, so the Mac widget could never share this suite.
  nonisolated(unsafe) static let sharedUserDefault = UserDefaults(suiteName: "group.uriphium.tiangandizhi")
}
