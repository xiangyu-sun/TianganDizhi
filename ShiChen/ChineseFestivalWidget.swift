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
  /// Not `@Environment`: a `Widget` isn't a `View`, so that only ever read the
  /// default and ignored the 使用系統字體 setting.
  private var largeTitleFont: Font { FontProvider.storedLargeTitleFont }

  var body: some WidgetConfiguration {
    IntentConfiguration(
      kind: kind,
      intent: ConfigurationIntent.self,
      provider: JieqiTimelineProvider(refreshesDaily: true)
    ) { entry in
      SpecialDayWidgetView(date: entry.date, largeTitleFont: largeTitleFont)
        .widgetDeepLink(kind: kind)
    }
    .configurationDisplayName(WidgetConstants.specialDayWidgetTitle)
    .description(WidgetConstants.specialDayWidgetDescription)
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// MARK: - SpecialDayWidgetView

struct SpecialDayWidgetView: View {
  let date: Date
  let largeTitleFont: Font

  @Environment(\.widgetFamily) private var family

  var body: some View {
    switch family {
    case .systemMedium:
      SpecialDayMediumView(date: date)
    default:
      small
    }
  }

  private var small: some View {
    // Same sources as the 節日曆 screen: built-in festivals, solar terms and
    // the user's 自訂節日, all on the 東八區 setting's calendar day.
    let upcoming = date.currentOrNextSpecialDay(
      sources: SpecialDayCatalog.sources(),
      calendar: .solarTerm
    )

    return VStack(alignment: .center) {
      Text(date, style: .date)
        .font(.callout)

      if let upcoming {
        Text(upcoming.day.name)
          .foregroundStyle(upcoming.daysUntil == 0 ? .primary : .secondary)
          .font(largeTitleFont)
          .minimumScaleFactor(0.5)
          .lineLimit(1)

        Text(upcoming.daysUntil.daysUntilText)
          .font(.callout)
          .foregroundStyle(upcoming.daysUntil == 0 ? Color.orange : Color.secondary)
      } else {
        // No upcoming special day found — show today's 節氣 rather than an
        // empty widget with only the background.
        Text(date.jieQiDisplayText)
          .font(largeTitleFont)
          .minimumScaleFactor(0.5)
          .lineLimit(1)
      }
    }
    // One locale for every date on the widget, matching the app's
    // Traditional Chinese UI.
    .environment(\.locale, Locale(identifier: "zh-Hant"))
    .widgetAccentable()
    .frame(maxWidth: .infinity)
    .materialBackgroundWidget(with: Image("background"))
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

#Preview("今日節日", as: .systemSmall, widget: {
  SpecialDayWidget()
}, timeline: {
  SimpleEntry(date: .springFestival2026, configuration: ConfigurationIntent())
})

#Preview("即將到來", as: .systemSmall, widget: {
  SpecialDayWidget()
}, timeline: {
  SimpleEntry(date: .beforeSpringFestival2026, configuration: ConfigurationIntent())
})

#Preview("中尺寸", as: .systemMedium, widget: {
  SpecialDayWidget()
}, timeline: {
  SimpleEntry(date: .beforeSpringFestival2026, configuration: ConfigurationIntent())
})

#Preview("遙遠節日", as: .systemSmall, widget: {
  SpecialDayWidget()
}, timeline: {
  SimpleEntry(date: Date(), configuration: ConfigurationIntent())
})

#endif

