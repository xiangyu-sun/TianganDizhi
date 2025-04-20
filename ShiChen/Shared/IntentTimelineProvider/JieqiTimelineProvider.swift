//
//  ShichenTimelineProvider 2.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//


import ChineseAstrologyCalendar
import CoreLocation
import WidgetKit

@MainActor
struct JieqiTimelineProvider: IntentTimelineProvider {

  // MARK: Internal

  func placeholder(in _: Context) -> SimpleEntry {
    let configuration = ConfigurationIntent()
    configuration.date = Date().currentCalendarDateCompoenents
    if let location = LocationManager.shared.lastLocation {
      configuration.location = "\(String(describing: location))"
    }

    return SimpleEntry(date: Date(), configuration: configuration)
  }

  @available(iOSApplicationExtension 16.0, *, watchOS 9, *)
  func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
    defaultRecommendedIntents().map { intent in
      let description = Date().shichen?.dizhi.chineseCharactor ?? ""
      return IntentRecommendation(intent: intent, description: description)
    }
  }

  func getSnapshot(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (SimpleEntry) -> Void) {
    let entry = SimpleEntry(date: Date(), configuration: configuration)
    completion(entry)
  }

  func getTimeline(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
    var entries: [SimpleEntry] = []

    configuration.date = Calendar.current.dateComponents(in: .current, from: Date())
    if let location = LocationManager.shared.lastLocation {
      configuration.location = "\(String(describing: location))"
    }

    for date in DailyTimeLineSceduler.buildTimeLine() {
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

  private func defaultRecommendedIntents() -> [ConfigurationIntent] {
    let configuration = ConfigurationIntent()
    configuration.date = Date().currentCalendarDateCompoenents
    if let location = LocationManager.shared.lastLocation {
      configuration.location = "\(String(describing: location))"
    }
    return [configuration]
  }
}

struct DailyTimeLineSceduler {
  static func buildTimeLine() -> [Date] {
    var timeline = [Date]()
    let currentDate = Date()

    timeline.append(currentDate)

    guard
      let currentShichen = currentDate.shichen else
    {
      return backup()
    }
    
    let entryDate = Calendar.current.date(byAdding: .second, value: 2, to: Date()) ?? Date()
    timeline.append(entryDate)

    for dayOffset in 1 ..< 15 {
      let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
      timeline.append(entryDate)
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
