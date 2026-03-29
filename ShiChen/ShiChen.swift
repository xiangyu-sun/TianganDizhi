//
//  ShiChenWidget.swift
//  ShiChenWidget
//
//  Created by 孙翔宇 on 02/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import Intents
import SwiftUI
import WidgetKit

// MARK: - ShiChen

struct ShiChen: Widget {
  let kind = "ShiChen"

  var iosSupportedFamilies: [WidgetFamily] {
    [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge, .accessoryInline, .accessoryRectangular]
  }

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: ShichenTimelineProvider()) { entry in
      ShiChenEntryView(entry: entry)
    }
    .configurationDisplayName(WidgetConstants.normalWidgetDisplayName)
    .description(WidgetConstants.normalWidgetDescription)
    #if os(watchOS)
      .supportedFamilies([.accessoryInline, .accessoryRectangular])
    #else
      .supportedFamilies(iosSupportedFamilies)
    #endif
  }
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

#if os(iOS)
#Preview("ShiChenYearMonthDateEntryView systemSmall") {
  ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .systemSmall))
}

#Preview("ShiChenEntryView systemSmall") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .systemSmall))
}

#Preview("ShiChenEntryView systemMedium") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .systemMedium))
}

#Preview("ShiChenEntryView systemLarge") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .systemLarge))
}

#Preview {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .systemLarge))
    .environment(\.colorScheme, .dark)
}

#Preview("systemExtraLarge") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
}

#Preview {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .systemMedium))
    .environment(\.sizeCategory, .extraExtraLarge)
}
#endif
