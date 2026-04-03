//
//  AllWidgets.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 23/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI

@main
struct AllWidgets: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    ShiChen()
    JieqiWidget()
    Nongli()
    HourlyWidget()
    CountDownWidget()
    if #available(iOSApplicationExtension 17.0, *) {
      JieqiHealthWidget()
    }
    // if #available(iOS 16.1, *) {
    //   ShichenLiveActivity()
    // }
  }

}
