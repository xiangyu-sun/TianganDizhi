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
      
      // Day-aligned, matching the main screen title (`jieQiDisplayText`): on a
      // term's start day highlight the term that has begun; otherwise highlight
      // the upcoming term and show its start date (the "days to next" the user
      // sees). Raw `entry.date.jieqi`/`nextJieqi` are instant-sensitive and, from
      // this widget's intraday seeds, drift a day on a transition morning.
      let isJieqiDay = entry.date.isJieqiDayAligned
      let occurrence = entry.date.displayedJieqi
      let jieqi = occurrence?.jieqi ?? entry.date.jieqiDayAligned ?? entry.date.jieqi

      // Grouped so the deep link applies to both branches.
      Group {
        if let jieqi {
          VStack(alignment: .center) {
            if isJieqiDay {
              Text(entry.date, style: .date)
                .font(.callout)
                .environment(\.locale, Locale.current)

              Text(jieqi.chineseName)
                .font(largeTitleFont)
            } else {
              Text(entry.date, style: .date)
                .font(.callout)
                .environment(\.locale, Locale(identifier: "zh-hant"))

              if let startDate = occurrence?.startDate {
                Text(startDate, style: .date)
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
