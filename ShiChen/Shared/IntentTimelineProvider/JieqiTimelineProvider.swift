//
//  ShichenTimelineProvider 2.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import CoreLocation
@preconcurrency import WidgetKit

// MARK: - JieqiTimelineProvider

struct JieqiTimelineProvider: IntentTimelineProvider {

  // MARK: Internal

  func placeholder(in _: Context) -> SimpleEntry {
    let configuration = ConfigurationIntent()
    configuration.date = Date().currentCalendarDateCompoenents
    if let location = cachedLastLocation() {
      configuration.location = "\(String(describing: location))"
    }

    return SimpleEntry(date: Date(), configuration: configuration)
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
    var entries: [SimpleEntry] = []

    configuration.date = Calendar.current.dateComponents(in: .current, from: Date())
    if let location = cachedLastLocation() {
      configuration.location = "\(String(describing: location))"
    }

    for date in ShichenTimeLineSceduler.buildTimeLine() {
      let entry = SimpleEntry(date: date, configuration: configuration)
      entries.append(entry)
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

  private func cachedLastLocation() -> CLLocation? {
    if let data = Constants.sharedUserDefault?.object(forKey: Constants.lastlocationKey) as? Data {
      return try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: data)
    }
    return nil
  }

  private func defaultRecommendedIntents() -> [ConfigurationIntent] {
    let configuration = ConfigurationIntent()
    configuration.date = Date().currentCalendarDateCompoenents
    if let location = cachedLastLocation() {
      configuration.location = "\(String(describing: location))"
    }
    return [configuration]
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
    let startOfToday = calendar.startOfDay(for: currentDate)
    for dayOffset in 1 ..< 15 {
      let startOfDay = calendar.date(byAdding: .day, value: dayOffset, to: startOfToday) ?? currentDate
      timeline.append(startOfDay)
    }
    return timeline
  }

  static func backup() -> [Date] {
    let currentDate = Date()
    var timeline = [Date]()
    for hourOffset in 0 ..< 15 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) ?? Date()
      timeline.append(entryDate)
    }
    return timeline
  }
}
