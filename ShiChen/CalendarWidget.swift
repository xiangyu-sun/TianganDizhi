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
        .widgetDeepLink(kind: kind)
    }
    .contentMarginsDisabled()
    .configurationDisplayName(WidgetConstants.calendarWidgetTitle)
    .description(WidgetConstants.calendarWidgetDescription)
    .supportedFamilies([.systemLarge, .systemExtraLarge])
  }
}

// MARK: - CalendarWidgetView

/// Header-less month calendar composed from the package's public parts, so the
/// interactive `MonthHeaderView` (whose buttons are inert in a widget) is omitted.
///
/// `.systemExtraLarge` only appears on iPad/Mac (WidgetKit doesn't offer it on
/// iPhone), and its canvas is much wider relative to its height than `.systemLarge`.
/// Rather than stretching the same 7-column grid, extraLarge adds a today-detail
/// sidebar (Four Pillars + Moon Phase) to use that extra horizontal space.
struct CalendarWidgetView: View {
  let entry: CalendarEntry

  @Environment(\.widgetFamily) private var family
  @Environment(\.calendarTheme) private var theme

  private var configuration: CalendarConfiguration {
    CalendarConfiguration(
      showLunarDays: entry.configuration.showLunarDays,
      showSolarTerms: entry.configuration.showSolarTerms)
  }

  private var month: CalendarMonth {
    CalendarMonth(containing: entry.date)
  }

  private var today: CalendarDate {
    CalendarDate(date: entry.date)
  }

  var body: some View {
    switch family {
    case .systemExtraLarge:
      HStack(alignment: .top, spacing: 16) {
        calendarGrid
          .frame(maxWidth: .infinity)

        VStack(alignment: .leading, spacing: 12) {
          FourPillarsView(calendarDate: today)
          MoonPhaseView(calendarDate: today)
          
          let mansion = LunarMansion.lunarMansion(date: entry.date)
          HStack {
            Text("星象: \(mansion.fourSymbol.rawValue)")
            Text("星宿: \(mansion.rawValue)")
          }
          .accessibilityElement(children: .combine)
          .accessibilityLabel("星象：\(mansion.fourSymbol.rawValue)，星宿：\(mansion.rawValue)")
          Spacer(minLength: 0)
        }
        .frame(width: 220)
      }
      .padding(.top, 16)
      .padding(.trailing, 16)
    default:
      calendarGrid
    }
  }

  private var calendarGrid: some View {
    let month = month

    // `.adaptiveCalendarColumns` (from the package) measures available width
    // and adapts columnSpacing/fonts to it, so a cramped `.systemLarge` on
    // iPhone and a roomy `.systemExtraLarge` on iPad don't render identically.
    // The adapted theme is shared via the environment, so WeekdayHeaderView and
    // CalendarDayGridView (below) both read the same value and stay aligned.
    return VStack(spacing: theme.rowSpacing) {
      VStack(alignment: .center, spacing: 0){
        Text(month.title)
        Text(entry.date.displayStringOfChineseYearMonthDateWithZodiac)
      }
      .font(.headline)
      .padding(.bottom, 8)

      WeekdayHeaderView(calendar: month.calendar)

      CalendarDayGridView(month: month, configuration: configuration, today: entry.date)
    }
    .adaptiveCalendarColumns(baseTheme: theme)
  }
}

// MARK: - CalendarDayGridView

/// The 7-column day grid, split into its own view (rather than inline in
/// `calendarGrid`) so it reads `calendarTheme` fresh from its own environment —
/// matching `WeekdayHeaderView`/`DayCellView`. That's what lets
/// `.adaptiveCalendarColumns` (applied on the parent `VStack`) reach it.
private struct CalendarDayGridView: View {
  let month: CalendarMonth
  let configuration: CalendarConfiguration
  /// The entry's date, not the system clock — WidgetKit pre-renders future
  /// entries at delivery time, so `DayCellView` must be told which day is
  /// "today" from the timeline entry, or it highlights the render-day's cell.
  let today: Date

  @Environment(\.calendarTheme) private var theme

  var body: some View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: theme.columnSpacing), count: 7)

    LazyVGrid(columns: columns, spacing: theme.rowSpacing) {
      ForEach(Array(month.gridDates.enumerated()), id: \.offset) { _, calDate in
        if let calDate {
          DayCellView(calendarDate: calDate, configuration: configuration, today: today)
        } else {
          Color.clear
        }
      }
    }
    .padding(.horizontal)
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
