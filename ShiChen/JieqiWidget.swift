//
//  Jieqi.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//

import WidgetKit
import ChineseAstrologyCalendar
import Intents
import SwiftUI
import Astral

 // MARK: - Jieqi


struct JieqiWidget: Widget {
  let kind = "Jieqi"
  @Environment(\.largeTitleFont) var largeTitleFont
  var iosSupportedFamilies: [WidgetFamily] {
    return [.systemSmall]
  }

  func getDate(date: Date) -> Date {

    let nextDate = preciseNextSolarTermDate(from: date)
    
    let interval = nextDate.timeIntervalSince(date)
    let days = Int(ceil(interval / 86_400))  // floor of full days
    
    if days <= 14 {
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
              .environment(\.locale, .init(identifier: "zh-Hant"))
            
            Text(jieqi.chineseName)
              .font(largeTitleFont)
          } else {
            Text(entry.date, style: .date)
              .font(.callout)
              .environment(\.locale, .init(identifier: "zh-Hant"))
            Text(date, style: .date)
              .font(.callout)
              .foregroundColor(.secondary)
              .environment(\.locale, .init(identifier: "zh-Hant"))
            
            Text(jieqi.chineseName)
              .foregroundColor(.secondary)
              .font(largeTitleFont)
          }
        }
        .frame(maxWidth: .infinity)
        .materialBackgroundWidget(with: Image(uiImage: jieqi.image))
      }
      else {
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
