//
//  ShichenTimelineProvider 2.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
@preconcurrency import WidgetKit

// MARK: - JieqiTimelineProvider

struct JieqiTimelineProvider: IntentTimelineProvider {

  // MARK: Internal

  func placeholder(in _: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), configuration: ConfigurationIntent())
  }

  func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
    defaultRecommendedIntents().map { intent in
      let description = Date().shichen?.dizhi.chineseCharacter ?? ""
      return IntentRecommendation(intent: intent, description: "二十四節氣桌面組件" + description)
    }
  }

  func getSnapshot(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (SimpleEntry) -> Void) {
    let entry = SimpleEntry(date: Date(), configuration: configuration)
    completion(entry)
  }

  func getTimeline(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
    // `configuration.date`/`.location` are not user-configurable and nothing
    // reads them, so they are left alone (see ShichenTimelineProvider).
    var entries: [SimpleEntry] = []
    for date in ShichenTimeLineSceduler.buildTimeLine() {
      entries.append(SimpleEntry(date: date, configuration: configuration))
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }

  @available(macOSApplicationExtension 15.0, *)
  @available(watchOSApplicationExtension 11.0, *)
  @available(iOSApplicationExtension 18.0, *)
  func relevance() async -> WidgetRelevance<ConfigurationIntent> {
    .init([.init(configuration: ConfigurationIntent(), context: .date(Date()))])
  }

  // MARK: Private


  private func defaultRecommendedIntents() -> [ConfigurationIntent] {
    [ConfigurationIntent()]
  }
}

// MARK: - DailyTimeLineSceduler

enum DailyTimeLineSceduler {
  static func buildTimeLine() -> [Date] {
    var timeline = [Date]()
    let currentDate = Date()
    let calendar = Calendar.current

    timeline.append(currentDate)

    guard currentDate.shichen != nil else {
      return backup()
    }

    // Anchor future entries at midnight boundaries so the widget refreshes
    // at the start of each calendar day, keeping the countdown in sync with
    // the main screen's real-time display.
    // A `?? currentDate` fallback here would re-insert the first entry's
    // exact date in the middle of the list, violating WidgetKit's
    // strictly-increasing timeline requirement. Skipping a failed entry
    // instead just shortens the timeline by one step.
    let startOfToday = calendar.startOfDay(for: currentDate)
    for dayOffset in 1 ..< 15 {
      if let startOfDay = calendar.date(byAdding: .day, value: dayOffset, to: startOfToday) {
        timeline.append(startOfDay)
      }
    }
    return timeline
  }

  static func backup() -> [Date] {
    let currentDate = Date()
    var timeline = [Date]()
    for hourOffset in 0 ..< 15 {
      if let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) {
        timeline.append(entryDate)
      }
    }
    return timeline
  }
}
