//
//  Jieqi.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import Intents
import SwiftUI
import WidgetKit

// MARK: - JieqiWidget

struct JieqiWidget: Widget {
  let kind = "Jieqi"
  /// Not `@Environment`: a `Widget` isn't a `View`, so that only ever read the
  /// default and ignored the 使用系統字體 setting.
  private var largeTitleFont: Font { FontProvider.storedLargeTitleFont }
  
  var iosSupportedFamilies: [WidgetFamily] {
    [.systemSmall]
  }

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: JieqiTimelineProvider()) { entry in
      
      // Day-aligned, matching the main screen title (`jieQiDisplayText`): on a
      // term's start day highlight the term that has begun; otherwise highlight
      // the upcoming term and show its start date (the "days to next" the user
      // sees). The day-aligned helpers reckon days in the user's chosen time
      // zone (使用東八區), the same as every other surface.
      let isJieqiDay = entry.date.isJieqiDayAligned
      let occurrence = entry.date.displayedJieqi
      let jieqi = occurrence?.jieqi ?? entry.date.jieqiDayAligned

      // Grouped so the deep link applies to both branches.
      Group {
        if let jieqi {
          // Short dates plus a countdown rather than two full dates: two
          // "2026年10月14日"-style lines overflowed the small width and didn't
          // say which date was which. Laid out like the small 節氣與節日 widget.
          VStack(alignment: .center) {
            Text(entry.date, format: Self.todayFormat)
              .font(.callout)
              .lineLimit(1)
              .minimumScaleFactor(0.7)

            Text(jieqi.chineseName)
              .foregroundStyle(isJieqiDay ? .primary : .secondary)
              .font(largeTitleFont)
              .lineLimit(1)
              .minimumScaleFactor(0.5)

            if isJieqiDay {
              Text(0.daysUntilText)
                .font(.callout)
                .foregroundStyle(Color.orange)
            } else if let occurrence {
              let days = occurrence.days(from: entry.date, calendar: .solarTerm)
              Text("\(days.daysUntilText) · \(occurrence.startDate.formatted(Self.startDayFormat))")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
          }
          .environment(\.locale, Locale(identifier: "zh-Hant"))
          .widgetAccentable()
          .frame(maxWidth: .infinity)
          #if os(macOS)
          .materialBackgroundWidget(with: Image(nsImage: jieqi.image))
          #else
          .materialBackgroundWidget(with: Image(uiImage: jieqi.image))
          #endif
        } else {
          EmptyView()
        }
      }
      .widgetDeepLink(kind: kind)
    }
    .configurationDisplayName(WidgetConstants.jieqiWidgetTitle)
    .description(WidgetConstants.jieqiWidgetDescription)
    .supportedFamilies(iosSupportedFamilies)
  }

  /// e.g. "10月14日 週三".
  private static let todayFormat = Date.FormatStyle(locale: Locale(identifier: "zh-Hant"))
    .month().day().weekday(.abbreviated)

  /// e.g. "10月23日", in the solar-term time zone the start date is reckoned in.
  private static var startDayFormat: Date.FormatStyle {
    Date.FormatStyle(locale: Locale(identifier: "zh-Hant"), timeZone: .solarTerm).month().day()
  }
}

extension View {
  func materialBackgroundWidget(with image: Image) -> some View {
    containerBackground(for: .widget, content: {
      image.resizable()
    })
  }

  func materialBackground(with image: Image) -> some View {
    modifier(MaterialBackground(image: image, toogle: false))
  }
}
