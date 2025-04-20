//
//  WidgetConstants.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 4/1/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
enum WidgetConstants {
  static let simpleWidgetTitle: LocalizedStringKey = "農曆年月日"
  static let simpleWidgetDescription: LocalizedStringKey = "顯示十二地支為命名基礎的農曆年，月，日以及時辰的小組件。桌面組件需要您在鎖屏介面長按屏幕來配置。"

  static let normalWidgetDisplayName: LocalizedStringKey = "農曆年月日以及十二时辰，臟器，月相"
  static let normalWidgetDescription: LocalizedStringKey = "顯示以十二地支為命名基礎的農曆年，月，日，俗稱，以及相關臟器信息的小組件。桌面組件需要您在鎖屏介面長按屏幕來配置。"

  static let countDownWidgetTitle: LocalizedStringKey = "節日倒數"
  static let countDownWidgetDescription: LocalizedStringKey = "農曆新年倒數組件"
  
  static let jieqiWidgetTitle: LocalizedStringKey = "二十四節氣"
  static let jieqiWidgetDescription: LocalizedStringKey = "小組件隨節氣變換"

}
