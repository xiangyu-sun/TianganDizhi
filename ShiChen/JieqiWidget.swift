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
