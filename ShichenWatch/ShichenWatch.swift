//
//  ShichenWatch.swift
//  ShichenWatch
//
//  Created by Xiangyu Sun on 24/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import AppIntents
import Intents
import SwiftUI
import WidgetKit

// MARK: - HourlyWidget

struct HourlyWidget: Widget {
  let kind = "ShiChenByMinute"

  var supportedFamilies: [WidgetFamily] {
    [.accessoryCircular, .accessoryCorner]
  }

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: MinuteTimelineProvider()) { entry in
      ShiChenEntryView(entry: entry)
    }
    .configurationDisplayName(WidgetConstants.simpleWidgetTitle)
    .description(WidgetConstants.simpleWidgetDescription)
    .supportedFamilies(supportedFamilies)
  }
}

// MARK: - ShiChenWidget

struct ShiChenWidget: Widget {
  let kind = "ShiChen"
  var supportedFamilies: [WidgetFamily] {
    [.accessoryInline, .accessoryRectangular]
  }

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: ShichenTimelineProvider()) { entry in
      ShiChenEntryView(entry: entry)
    }
    .configurationDisplayName(WidgetConstants.normalWidgetDisplayName)
    .description(WidgetConstants.normalWidgetDescription)
    .supportedFamilies(supportedFamilies)
  }
}

#Preview("YearMonth Inline") {
  ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .accessoryInline))
}

#Preview("YearMonth Circular") {
  ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
}

#Preview("YearMonth Retangular") {
  ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
}

#Preview("ShiChenEntryView Inline") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .accessoryInline))
}

#Preview("ShiChenEntryView Circular") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
}

#Preview("ShiChenEntryView Retangular") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
}

#Preview("ShiChenEntryView accessoryCorner") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .accessoryCorner))
}
