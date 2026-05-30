//
//  LuckWidget.swift
//  TianganDizhi
//

import AppIntents
import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - LuckConfigurationIntent

@available(iOSApplicationExtension 17.0, *)
struct LuckConfigurationIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "今日宜忌配置"
  static let description: IntentDescription? = IntentDescription("顯示今日建除神及宜忌事項")
}

// MARK: - LuckEntry

@available(iOSApplicationExtension 17.0, *)
struct LuckEntry: TimelineEntry {
  let date: Date
  let configuration: LuckConfigurationIntent
}

// MARK: - LuckTimelineProvider

@available(iOSApplicationExtension 17.0, *)
struct LuckTimelineProvider: AppIntentTimelineProvider {

  func placeholder(in _: Context) -> LuckEntry {
    LuckEntry(date: Date(), configuration: LuckConfigurationIntent())
  }

  func recommendations() -> [AppIntentRecommendation<LuckConfigurationIntent>] {
    [AppIntentRecommendation(intent: LuckConfigurationIntent(), description: "今日宜忌")]
  }

  func snapshot(for configuration: LuckConfigurationIntent, in _: Context) async -> LuckEntry {
    LuckEntry(date: Date(), configuration: configuration)
  }

  func timeline(for configuration: LuckConfigurationIntent, in _: Context) async -> Timeline<LuckEntry> {
    let entries = ShichenTimeLineSceduler.buildTimeLine().map {
      LuckEntry(date: $0, configuration: configuration)
    }
    return Timeline(entries: entries, policy: .atEnd)
  }
}

// MARK: - LuckWidget

@available(iOSApplicationExtension 17.0, *)
struct LuckWidget: Widget {
  let kind = "LuckWidget"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: LuckConfigurationIntent.self,
      provider: LuckTimelineProvider()
    ) { entry in
      LuckRectangularWidgetView(date: entry.date)
    }
    .configurationDisplayName("今日宜忌")
    .description("顯示今日建除神、宜忌事項及日支沖")
    .supportedFamilies([.accessoryRectangular])
  }
}

// MARK: - Preview

@available(iOSApplicationExtension 17.0, *)
#Preview(as: .accessoryRectangular, widget: {
  LuckWidget()
}, timeline: {
  LuckEntry(date: Date(), configuration: .init())
})
