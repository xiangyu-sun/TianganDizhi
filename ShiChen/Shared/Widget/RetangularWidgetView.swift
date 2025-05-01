//
//  RetangularWidgetView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 26/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI
import WidgetKit
import Astral
import ChineseAstrologyCalendar

// MARK: - RetangularWidgetView

extension Date {
  var jieQi: String? {
    if let jieqi = Jieqi.current {
      let nextDate = preciseNextSolarTermDate()

      let interval = nextDate.timeIntervalSince(Date())
      let days = Int(floor(interval / 86_400))

      if days < 1 {
        return jieqi.chineseName
      }

    }
    return nil
  }
}


@available(iOS 16.0, *)
struct RetangularWidgetView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.calloutFont) var calloutFont
  @Environment(\.titleFont) var titleFont
  @Environment(\.title3Font) var title3Font

  @State var date: Date

  var body: some View {
    let shichen = date.shichen

    HStack {
      Text(date.displayStringOfChineseYearMonthDateWithZodiac + (date.jieQi ?? ""))
        .font(.body)
      Text(shichen?.dizhi.displayHourText ?? "")
        .font(.body)

    }
    .widgetAccentable()
    .containerBackgroundForWidget(content: { Color.clear })
  }
}

// MARK: - RetangularWidgetView_Previews

@available(iOS 16.0, *)
struct RetangularWidgetView_Previews: PreviewProvider {
  static var previews: some View {
    #if os(macOS)
    RetangularWidgetView(date: .now)
      .previewContext(WidgetPreviewContext(family: .systemSmall))
    #else

    RetangularWidgetView(date: .now)
      .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    #endif
  }
}
