//
//  ShichenMacWidget.swift
//  ShichenMacWidget
//
//  Created by Xiangyu Sun on 14/11/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import Intents
import SwiftUI
import WidgetKit

// MARK: - ShichenMacWidget

@main
struct ShichenMacWidget: Widget {
  let kind = "ShiChen"

  var supportedFamilies: [WidgetFamily] {
    [.systemSmall, .systemMedium, .systemLarge]
  }

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: ShichenTimelineProvider()) { entry in
      ShiChenEntryView(entry: entry)
    }
    .configurationDisplayName("十二时辰")
    .description("十二地支为名的十二时辰计，俗稱，以及相關臟器")
    .supportedFamilies(supportedFamilies)
  }
}

// MARK: - ShichenMacWidget_Previews

struct ShichenMacWidget_Previews: PreviewProvider {
  static var previews: some View {
    ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}
