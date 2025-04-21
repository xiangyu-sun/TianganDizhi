//
//  Nongli.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//
import ChineseAstrologyCalendar
import Intents
import SwiftUI
import WidgetKit

// MARK: - Nongli

struct Nongli: Widget {
  let kind = "Nongli"

  var supportedFamilies: [WidgetFamily] {
    if #available(iOSApplicationExtension 16.0, *) {
      [.systemSmall, .systemMedium, .accessoryInline, .accessoryCircular, .accessoryRectangular]
    } else {
      [.systemSmall, .systemMedium]
    }
  }

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: ShichenTimelineProvider()) { entry in
      ShiChenYearMonthDateEntryView(entry: entry)
    }
    .configurationDisplayName(WidgetConstants.simpleWidgetTitle)
    .description(WidgetConstants.simpleWidgetDescription)
    #if os(watchOS)
      .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular])
    #else

      .supportedFamilies(supportedFamilies)
    #endif
  }
}
