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
    if #available(iOSApplicationExtension 16.0, *) {
      return [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge, .accessoryInline, .accessoryRectangular]
    } else if #available(iOSApplicationExtension 15.0, *) {
      return [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
    } else {
      return [.systemSmall, .systemMedium, .systemLarge]
    }
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

// MARK: - ShiChen_Previews

struct ShiChen_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      if #available(iOSApplicationExtension 16.0, *) {
        ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryInline))
          .previewDisplayName("ShiChenEntryView Inline")
        ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryCircular))
          .previewDisplayName("ShiChenEntryView Circular")

        ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
          .previewDisplayName("ShiChenEntryView Retangular")
      }
    }

    #if os(iOS)
    Group {
      ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("ShiChenYearMonthDateEntryView systemSmall")

      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("ShiChenEntryView systemSmall")

      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .previewDisplayName("ShiChenEntryView systemMedium")

      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemLarge))
        .previewDisplayName("ShiChenEntryView systemLarge")

      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemLarge))
        .environment(\.colorScheme, .dark)
      if #available(iOSApplicationExtension 15.0, *) {
        ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
          .previewDisplayName("systemExtraLarge")
      }

      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .environment(\.sizeCategory, .extraExtraLarge)
    }
    #endif
  }
}
