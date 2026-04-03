//
//  JieqiHealthWidget.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 3/4/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import AppIntents
import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - JieqiHealthConfigurationIntent

@available(iOSApplicationExtension 17.0, *)
struct JieqiHealthConfigurationIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "節氣養生配置"
  static let description: IntentDescription? = IntentDescription("二十四節氣養生提示")
}

// MARK: - JieqiHealthEntry

@available(iOSApplicationExtension 17.0, *)
struct JieqiHealthEntry: TimelineEntry {
  let date: Date
  let configuration: JieqiHealthConfigurationIntent
}

// MARK: - JieqiHealthTimelineProvider

@available(iOSApplicationExtension 17.0, *)
struct JieqiHealthTimelineProvider: AppIntentTimelineProvider {

  func placeholder(in _: Context) -> JieqiHealthEntry {
    JieqiHealthEntry(date: Date(), configuration: JieqiHealthConfigurationIntent())
  }

  func snapshot(for configuration: JieqiHealthConfigurationIntent, in _: Context) async -> JieqiHealthEntry {
    JieqiHealthEntry(date: Date(), configuration: configuration)
  }

  func timeline(for configuration: JieqiHealthConfigurationIntent, in _: Context) async -> Timeline<JieqiHealthEntry> {
    var entries: [JieqiHealthEntry] = []

    for date in DailyTimeLineSceduler.buildTimeLine() {
      entries.append(JieqiHealthEntry(date: date, configuration: configuration))
    }

    return Timeline(entries: entries, policy: .atEnd)
  }
}

// MARK: - JieqiHealthWidget

@available(iOSApplicationExtension 17.0, *)
struct JieqiHealthWidget: Widget {
  let kind = "JieqiHealth"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: JieqiHealthConfigurationIntent.self,
      provider: JieqiHealthTimelineProvider())
    { entry in
      JieqiHealthMediumView(date: entry.date)
    }
    .configurationDisplayName(WidgetConstants.jieqiHealthWidgetTitle)
    .description(WidgetConstants.jieqiHealthWidgetDescription)
    .supportedFamilies([.systemMedium])
  }
}

// MARK: - Previews

@available(iOSApplicationExtension 17.0, *)
#Preview(as: .systemMedium, widget: {
  JieqiHealthWidget()
}, timeline: {
  JieqiHealthEntry(date: Date(), configuration: .init())
})
