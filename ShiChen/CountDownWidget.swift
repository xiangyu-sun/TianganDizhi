//
//  CountDownWidget.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 6/1/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import SwiftUI
import WidgetKit

struct CountDownWidget: Widget {
  let kind = "com.uriphium.tinagandizhi.countdown.widget"

  var supportedFamilies: [WidgetFamily] {
    #if os(iOS)
    if #available(iOSApplicationExtension 16.0, *) {
      return [.systemSmall, .systemMedium, .accessoryInline, .accessoryRectangular]
    } else {
      return [.systemSmall, .systemMedium]
    }
    #elseif os(watchOS)
    return [.accessoryInline, .accessoryRectangular]
    #else
    return [.systemSmall, .systemMedium]
    #endif
  }

  var body: some WidgetConfiguration {
    
    IntentConfiguration(kind: kind, intent: CountDownIntentConfigurationIntent.self, provider: CountDownTimelineProvider()) { entry in
      CountDownView(entry: entry)
    }
    .configurationDisplayName(WidgetConstants.countDownWidgetTitle)
    .description(WidgetConstants.countDownWidgetDescription)
    #if os(watchOS)
      .supportedFamilies([.accessoryInline, .accessoryRectangular])
    #else

      .supportedFamilies(supportedFamilies)
    #endif
  }
}
