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
  @Environment(\.largeTitleFont) var largeTitleFont
  
  var iosSupportedFamilies: [WidgetFamily] {
    [.systemSmall]
  }

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: JieqiTimelineProvider()) { entry in
      // Show upcoming jieqi if within 14 days, otherwise show current.
      let upcomingResult = entry.date.nextJieqi
      let jieqi: Jieqi? = {
        if let upcoming = upcomingResult, upcoming.days <= 14 {
          return upcoming.jieqi
        }
        return entry.date.jieqi
      }()
      // sameCalendarDay: the solar term is today (days == 0)
      let sameCalendarDay = upcomingResult?.days == 0

      if let jieqi {
        VStack(alignment: .center) {
          if sameCalendarDay {
            Text(entry.date, style: .date)
              .font(.callout)
              .environment(\.locale, Locale.current)

            Text(jieqi.chineseName)
              .font(largeTitleFont)
          } else {
            Text(entry.date, style: .date)
              .font(.callout)
              .environment(\.locale, Locale(identifier: "zh-hant"))

            if let jieqiDate = jieqi.nextDate(after: entry.date) {
              Text(jieqiDate, style: .date)
                .font(.callout)
                .foregroundStyle(.secondary)
                .environment(\.locale, Locale(identifier: "zh-hant"))
            }

            Text(jieqi.chineseName)
              .foregroundStyle(.secondary)
              .font(largeTitleFont)
          }
        }
        .widgetAccentable()
        .frame(maxWidth: .infinity)
        .materialBackgroundWidget(with: Image(uiImage: jieqi.image))
      } else {
        EmptyView()
      }
    }
    .configurationDisplayName(WidgetConstants.jieqiWidgetTitle)
    .description(WidgetConstants.jieqiWidgetDescription)
    .supportedFamilies(iosSupportedFamilies)
  }
}

extension View {
  func materialBackgroundWidget(with image: Image) -> some View {
    if #available(iOS 17.0, watchOS 10.0, macOS 14.0, *) {
      return containerBackground(for: .widget, content: {
        image.resizable()
      })
    } else {
      return modifier(MaterialBackground(image: image, toogle: false))
    }
  }

  func materialBackground(with image: Image) -> some View {
    modifier(MaterialBackground(image: image, toogle: false))
  }
}
