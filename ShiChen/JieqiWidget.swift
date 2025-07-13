//
//  Jieqi.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//

import Astral
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

  func getDate(date: Date) -> Date {
    let nextDate = preciseNextSolarTermDate(from: date)
    
    let days = nextDate.dayDifference(date)

    if days >= 1 && days <= 14 {
      return nextDate
    } else {
      return date
    }
  }

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: JieqiTimelineProvider()) { entry in
      let date = getDate(date: entry.date)
      let sameDate = date == entry.date

      if let jieqi = date.jieqi {
        VStack(alignment: .center) {
          if sameDate {
            Text(date, style: .date)
              .font(.callout)
              .environment(\.locale, Locale.current)

            Text(jieqi.chineseName)
              .font(largeTitleFont)
          } else {
            Text(entry.date, style: .date)
              .font(.callout)
              .environment(\.locale, Locale.current)
            Text(date, style: .date)
              .font(.callout)
              .foregroundColor(.secondary)
              .environment(\.locale, Locale.current)

            Text(jieqi.chineseName)
              .foregroundColor(.secondary)
              .font(largeTitleFont)
          }
        }
        .modifier(WidgetAccentable())
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
