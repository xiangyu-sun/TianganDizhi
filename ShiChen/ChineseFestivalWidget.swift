//
//  ChineseFestivalWidget.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 10/5/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import Intents
import SwiftUI
import WidgetKit


// MARK: - ChineseFestivalWidget

struct ChineseFestivalWidget: Widget {
  let kind = "ChineseFestival"
  @Environment(\.largeTitleFont) var largeTitleFont

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: JieqiTimelineProvider()) { entry in
      let festival = entry.date.chineseFestival

      // Find the next upcoming festival within 14 days
      let converter = DayConverter()
      let upcoming: (festival: ChineseFestival, date: Date, days: Int)? = {
        let upcomingFestivals = ChineseFestival.allCases.compactMap { f -> (festival: ChineseFestival, date: Date, days: Int)? in
          guard let nextDate = f.nextDate(from: entry.date, converter: converter) else { return nil }
          let days = Calendar.current.dateComponents([.day], from: entry.date, to: nextDate).day ?? Int.max
          return (f, nextDate, days)
        }
        return upcomingFestivals.min(by: { $0.days < $1.days })
      }()

      VStack(alignment: .center) {
        if let festival {
          // Today is a festival
          Text(entry.date, style: .date)
            .font(.callout)
            .environment(\.locale, Locale.current)

          Text(festival.chineseName)
            .font(largeTitleFont)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
        } else if let upcoming, upcoming.days <= 14 {
          // Upcoming festival within 14 days
          Text(entry.date, style: .date)
            .font(.callout)
            .environment(\.locale, Locale(identifier: "zh-hant"))

          Text(upcoming.date, style: .date)
            .font(.callout)
            .foregroundStyle(.secondary)
            .environment(\.locale, Locale(identifier: "zh-hant"))

          Text(upcoming.festival.chineseName)
            .foregroundStyle(.secondary)
            .font(largeTitleFont)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
        } else if let upcoming {
          // Show next festival even if far away — same layout as within-14-days
          Text(entry.date, style: .date)
            .font(.callout)
            .environment(\.locale, Locale(identifier: "zh-hant"))

          Text(upcoming.date, style: .date)
            .font(.callout)
            .foregroundStyle(.secondary)
            .environment(\.locale, Locale(identifier: "zh-hant"))

          Text(upcoming.festival.chineseName)
            .foregroundStyle(.secondary)
            .font(largeTitleFont)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
        }
      }
      .widgetAccentable()
      .frame(maxWidth: .infinity)
      .materialBackgroundWidget(with: Image("background"))
    }
    .configurationDisplayName(WidgetConstants.chineseFestivalWidgetTitle)
    .description(WidgetConstants.chineseFestivalWidgetDescription)
    .supportedFamilies([.systemSmall])
  }
}

#if DEBUG
// A fixed date known to be 春節 (Chinese New Year) for preview purposes
private extension Date {
  static var springFestival2026: Date {
    // 2026-02-17 is 春節
    var components = DateComponents()
    components.year = 2026
    components.month = 2
    components.day = 17
    return Calendar.current.date(from: components) ?? Date()
  }
  
  static var beforeSpringFestival2026: Date {
    // 10 days before 春節
    Calendar.current.date(byAdding: .day, value: -10, to: .springFestival2026) ?? Date()
  }
}

// MARK: - Previews

@available(iOSApplicationExtension 17.0, *)
#Preview("今日節日", as: .systemSmall, widget: {
  ChineseFestivalWidget()
}, timeline: {
  SimpleEntry(date: .springFestival2026, configuration: ConfigurationIntent())
})

@available(iOSApplicationExtension 17.0, *)
#Preview("即將到來", as: .systemSmall, widget: {
  ChineseFestivalWidget()
}, timeline: {
  SimpleEntry(date: .beforeSpringFestival2026, configuration: ConfigurationIntent())
})

@available(iOSApplicationExtension 17.0, *)
#Preview("遙遠節日", as: .systemSmall, widget: {
  ChineseFestivalWidget()
}, timeline: {
  SimpleEntry(date: Date(), configuration: ConfigurationIntent())
})

#endif

