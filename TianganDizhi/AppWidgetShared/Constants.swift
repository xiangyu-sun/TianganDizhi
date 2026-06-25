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
  #if os(macOS)
  nonisolated(unsafe) static let sharedUserDefault = UserDefaults(suiteName: "group.R45U3GK22z.uriphium.tiangandizhi")
  #else
  nonisolated(unsafe) static let sharedUserDefault = UserDefaults(suiteName: "group.uriphium.tiangandizhi")
  #endif
}
