//
//  AllWidgets.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 23/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI
import WidgetKit

/// Applies the app's 語言 setting before WidgetKit starts; see `AppLanguage`.
@main
enum WidgetMain {
  static func main() {
    AppLanguage.applyAtLaunch()
    AllWidgets.main()
  }
}

struct AllWidgets: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    ShiChen()
    JieqiWidget()
    HourlyWidget()
    JieqiHealthWidget()
    CalendarWidget()
    SpecialDayWidget()
    CountDownWidget()
    Nongli()
    LuckWidget()
  }

}
