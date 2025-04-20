//
//  HourlyWidget.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import Intents
import SwiftUI
import WidgetKit

// MARK: - HourlyWidget

@available(iOSApplicationExtension 16.0, *)
struct HourlyWidget: Widget {
  let kind = "ShiChenByMinute"

  var supportedFamilies: [WidgetFamily] {
    [.accessoryCircular]
  }

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: MinuteTimelineProvider()) { entry in
      ShiChenEntryView(entry: entry)
    }
    .configurationDisplayName("十二时辰")
    .description("十二地支为名的十二时辰組件，更新频率为十五分鐘。")
    .supportedFamilies([.accessoryCircular])
  }
}
