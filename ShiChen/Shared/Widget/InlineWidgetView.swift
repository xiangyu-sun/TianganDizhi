//
//  InlineWidgetView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 26/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - InlineWidgetView

@available(iOS 16.1, *)
struct InlineWidgetView: View {

  @Environment(\.bodyFont) var bodyFont

  @State var date: Date

  var body: some View {
    let shichen = date.shichen

    ViewThatFits(in: .horizontal) {
      Text("\(date.displayStringOfChineseYearMonthDateWithZodiac) \(shichen?.dizhi.displayHourText ?? "")")
      Text(shichen?.dizhi.displayHourText ?? "")
    }
    .font(bodyFont)
    .widgetAccentable()
  }
}

// MARK: - InlineWidgetView_Previews

@available(iOSApplicationExtension 16.1, *)
struct InlineWidgetView_Previews: PreviewProvider {
  static var previews: some View {
    #if os(macOS)
    InlineWidgetView(date: .now)
      .previewContext(WidgetPreviewContext(family: .systemSmall))
    #else
    InlineWidgetView(date: .now)
      .previewContext(WidgetPreviewContext(family: .accessoryInline))
    #endif
  }
}
