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
    #if os(macOS)
    static let sharedUserDefault = UserDefaults(suiteName: "group.R45U3GK22z.uriphium.tiangandizhi")
    #else
    static let sharedUserDefault = UserDefaults(suiteName: "group.uriphium.tiangandizhi")
    #endif
}