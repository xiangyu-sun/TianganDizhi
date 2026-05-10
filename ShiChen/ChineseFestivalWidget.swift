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

// MARK: - SpecialDayWidget

struct SpecialDayWidget: Widget {
  let kind = "SpecialDay"
  @Environment(\.largeTitleFont) var largeTitleFont

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: JieqiTimelineProvider()) { entry in
      let upcoming: (day: SpecialDay, daysUntil: Int)? = entry.date.nextSpecialDay(
        sources: [JieqiSource(), FestivalSource()]
      )

      VStack(alignment: .center) {
        if let upcoming, upcoming.daysUntil == 0 {
          // Today is a special day
          Text(entry.date, style: .date)
            .font(.callout)
            .environment(\.locale, Locale.current)

          Text(upcoming.day.name)
            .font(largeTitleFont)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
        } else if let upcoming {
          // Upcoming special day — show today + its date + name
          Text(entry.date, style: .date)
            .font(.callout)
            .environment(\.locale, Locale(identifier: "zh-hant"))

          Text(upcoming.day.date, style: .date)
            .font(.callout)
            .foregroundStyle(.secondary)
            .environment(\.locale, Locale(identifier: "zh-hant"))

          Text(upcoming.day.name)
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
    .configurationDisplayName(WidgetConstants.specialDayWidgetTitle)
    .description(WidgetConstants.specialDayWidgetDescription)
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
  SpecialDayWidget()
}, timeline: {
  SimpleEntry(date: .springFestival2026, configuration: ConfigurationIntent())
})

@available(iOSApplicationExtension 17.0, *)
#Preview("即將到來", as: .systemSmall, widget: {
  SpecialDayWidget()
}, timeline: {
  SimpleEntry(date: .beforeSpringFestival2026, configuration: ConfigurationIntent())
})

@available(iOSApplicationExtension 17.0, *)
#Preview("遙遠節日", as: .systemSmall, widget: {
  SpecialDayWidget()
}, timeline: {
  SimpleEntry(date: Date(), configuration: ConfigurationIntent())
})

#endif

