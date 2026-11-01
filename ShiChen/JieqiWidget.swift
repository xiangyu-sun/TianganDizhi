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
      let language = DisplayLanguage.app
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
            Text(entry.date, format: Self.todayFormat(language))
              .font(.callout)
              .lineLimit(1)
              .minimumScaleFactor(0.7)

            Text(jieqi.localizedName(in: language.glyphLanguage))
              .foregroundStyle(isJieqiDay ? .primary : .secondary)
              .font(largeTitleFont)
              .lineLimit(1)
              .minimumScaleFactor(0.5)

            // The glyphs stay the headline; outside Chinese the English name follows.
            if !language.isChinese {
              Text(jieqi.localizedName(in: language))
                .font(.callout)
                .foregroundStyle(isJieqiDay ? .primary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }

            if isJieqiDay {
              Text(0.daysUntilText(language: language))
                .font(.callout)
                .foregroundStyle(Color.orange)
            } else if let occurrence {
              let days = occurrence.days(from: entry.date, calendar: .solarTerm)
              Text("\(days.daysUntilText(language: language)) · \(occurrence.startDate.formatted(Self.startDayFormat(language)))")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
          }
          .environment(\.locale, Self.locale(language))
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

  /// Traditional Chinese for Chinese, the device's locale otherwise.
  private static func locale(_ language: DisplayLanguage) -> Locale {
    language.isChinese ? Locale(identifier: "zh-Hant") : .autoupdatingCurrent
  }

  /// e.g. "10月14日 週三".
  private static func todayFormat(_ language: DisplayLanguage) -> Date.FormatStyle {
    Date.FormatStyle(locale: locale(language)).month().day().weekday(.abbreviated)
  }

  /// e.g. "10月23日", in the solar-term time zone the start date is reckoned in.
  private static func startDayFormat(_ language: DisplayLanguage) -> Date.FormatStyle {
    Date.FormatStyle(locale: locale(language), timeZone: .solarTerm).month().day()
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
