//
//  RetangularWidgetView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 26/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import Astral
import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - RetangularWidgetView

extension Date {
  var nextJieJiWithinOneDay: String? {
    if let jieqi = Jieqi.current {
      let nextDate = preciseNextSolarTermDate()

      let interval = nextDate.timeIntervalSince(Date())
      let days = Int(ceil(interval / 86_400)) // floor of full days

      if days < 1 {
        return jieqi.chineseName
      }
    }
    return nil
  }
}

@available(iOS 16.0, *)
struct RetangularWidgetView: View {
  @State var date: Date
  
  var god: String {
    date.twelveGod().map { "·" + $0.chinese } ?? ""
  }

  var body: some View {
    let shichen = date.shichen

    HStack {
     
      Text(date.displayStringOfChineseYearMonthDateWithZodiac + (date.nextJieJiWithinOneDay.map { "·" + $0 } ?? "") + god)
        .font(.body)
      Text(shichen?.dizhi.displayHourText ?? "")
        .font(.headline)
    }
    .widgetAccentable()
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
