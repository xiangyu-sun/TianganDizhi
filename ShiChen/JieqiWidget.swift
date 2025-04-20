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

 // MARK: - Jieqi

struct JieqiWidget: Widget {
  let kind = "Jieqi"
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.calloutFont) var calloutFont
  var iosSupportedFamilies: [WidgetFamily] {
    return [.systemSmall]
  }

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: JieqiTimelineProvider()) { entry in
      if let jieqi = entry.date.jieqi {
        VStack(alignment: .center) {
          Text(entry.date, style: .date)
            .font(calloutFont)
            .ignoresSafeArea(.all)
          Text(jieqi.chineseName)
            .font(largeTitleFont)
        }
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
