//
//  RetangularWidgetView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 26/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI
import WidgetKit

import ChineseAstrologyCalendar

// MARK: - RetangularWidgetView

@available(iOSApplicationExtension 16.0, *)
struct RetangularWidgetView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.titleFont) var titleFont
  @Environment(\.title3Font) var title3Font

  @State var date: Date

  var body: some View {
      let shichen = date.shichen

    HStack {
      Text(date.displayStringOfChineseYearMonthDateWithZodiac)
        .font(.custom(.weibeiBold, size: 20, relativeTo: .body))
        Text(shichen?.dizhi.displayHourText ?? "")
      #if os(watchOS)
        .font(titleFont)
      #else
        .font(title3Font)
      #endif
    }
    .widgetAccentable()
  }
}

// MARK: - RetangularWidgetView_Previews

@available(iOSApplicationExtension 16.0, *)
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
