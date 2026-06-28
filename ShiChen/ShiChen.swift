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
}

#Preview("ShiChenEntryView Circular") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("ShiChenEntryView Retangular") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#if os(iOS)
#Preview("ShiChenYearMonthDateEntryView systemSmall") {
  ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("ShiChenEntryView systemSmall") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("ShiChenEntryView systemMedium") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("ShiChenEntryView systemLarge") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("ShiChenEntryView Dark") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .environment(\.colorScheme, .dark)
}

#Preview("systemExtraLarge") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("systemMedium XXL") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .environment(\.sizeCategory, .extraExtraLarge)
}
#endif
