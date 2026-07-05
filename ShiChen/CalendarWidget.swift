//
//  CalendarWidget.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 5/7/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import AppIntents
import ChineseAstrologyCalendar
import ChineseTranditionalCalendarUI
import SwiftUI
import WidgetKit

// MARK: - CalendarConfigurationIntent

struct CalendarConfigurationIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "月曆配置"
  static let description: IntentDescription? = IntentDescription("農曆月曆組件")

  @Parameter(title: "顯示節氣", default: true)
  var showSolarTerms: Bool

  @Parameter(title: "顯示農曆日", default: true)
  var showLunarDays: Bool
}

// MARK: - CalendarEntry

struct CalendarEntry: TimelineEntry {
  let date: Date
  let configuration: CalendarConfigurationIntent
}

// MARK: - CalendarTimelineProvider

struct CalendarTimelineProvider: AppIntentTimelineProvider {

  func placeholder(in _: Context) -> CalendarEntry {
    CalendarEntry(date: Date(), configuration: CalendarConfigurationIntent())
  }

  func snapshot(for configuration: CalendarConfigurationIntent, in _: Context) async -> CalendarEntry {
    CalendarEntry(date: Date(), configuration: configuration)
  }

  func timeline(for configuration: CalendarConfigurationIntent, in _: Context) async -> Timeline<CalendarEntry> {
    // Entries anchored at midnight boundaries so the "today" highlight rolls
    // over at the start of each calendar day.
    let entries = DailyTimeLineSceduler.buildTimeLine().map {
      CalendarEntry(date: $0, configuration: configuration)
    }
    return Timeline(entries: entries, policy: .atEnd)
  }
}

// MARK: - CalendarWidget

struct CalendarWidget: Widget {
  let kind = "CalendarWidget"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: CalendarConfigurationIntent.self,
      provider: CalendarTimelineProvider())
    { entry in
      CalendarWidgetView(entry: entry)
        .containerBackground(.background, for: .widget)
    }
    .configurationDisplayName(WidgetConstants.calendarWidgetTitle)
    .description(WidgetConstants.calendarWidgetDescription)
    .supportedFamilies([.systemLarge, .systemExtraLarge])
  }
}

// MARK: - CalendarWidgetView

/// Header-less month calendar composed from the package's public parts, so the
/// interactive `MonthHeaderView` (whose buttons are inert in a widget) is omitted.
struct CalendarWidgetView: View {
  let entry: CalendarEntry

  private var configuration: CalendarConfiguration {
    CalendarConfiguration(
      showLunarDays: entry.configuration.showLunarDays,
      showSolarTerms: entry.configuration.showSolarTerms)
  }

  private var month: CalendarMonth {
    CalendarMonth(containing: entry.date)
  }

  var body: some View {
    let month = month
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    VStack(spacing: 6) {
      Text(month.title)
        .font(.headline)

      WeekdayHeaderView(calendar: month.calendar)

      LazyVGrid(columns: columns, spacing: 2) {
        ForEach(Array(month.gridDates.enumerated()), id: \.offset) { _, calDate in
          if let calDate {
            DayCellView(calendarDate: calDate, configuration: configuration)
          } else {
            Color.clear
          }
        }
      }
    }
    .padding(8)
  }
}

// MARK: - Previews

#Preview("systemLarge", as: .systemLarge) {
  CalendarWidget()
} timeline: {
  CalendarEntry(date: Date(), configuration: .init())
}

#Preview("systemExtraLarge", as: .systemExtraLarge) {
  CalendarWidget()
} timeline: {
  CalendarEntry(date: Date(), configuration: .init())
}
