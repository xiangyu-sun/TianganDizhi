//
//  ShichenWatch.swift
//  ShichenWatch
//
//  Created by Xiangyu Sun on 24/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import Intents
import SwiftUI
import WidgetKit

// MARK: - AllWidgets

@main
struct AllWidgets: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    ShiChen()
    HourlyWidget()
  }
}

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

// MARK: - ShiChen

struct ShiChen: Widget {
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

// MARK: - ShiChen_Previews

struct ShiChen_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .accessoryInline))
        .previewDisplayName("YearMonth Inline")

      ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        .previewDisplayName("YearMonth Circular")

      ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        .previewDisplayName("YearMonth Retangular")

      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .accessoryInline))
        .previewDisplayName("ShiChenEntryView Inline")

      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        .previewDisplayName("ShiChenEntryView Circular")

      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        .previewDisplayName("ShiChenEntryView Retangular")
      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .accessoryCorner))
        .previewDisplayName("ShiChenEntryView accessoryCorner")
    }
  }
}
