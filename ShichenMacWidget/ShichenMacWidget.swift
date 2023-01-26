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

// MARK: - AllWidgets

@main
struct AllWidgets: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    ShichenMacWidget()
    //CountDownWidget()
  }
}

// MARK: - ShichenMacWidget

struct ShichenMacWidget: Widget {
  let kind = "ShiChen"

  var supportedFamilies: [WidgetFamily] {
    [.systemSmall, .systemMedium, .systemLarge]
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

// MARK: - ShichenMacWidget_Previews

struct ShichenMacWidget_Previews: PreviewProvider {
  static var previews: some View {
    ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}
