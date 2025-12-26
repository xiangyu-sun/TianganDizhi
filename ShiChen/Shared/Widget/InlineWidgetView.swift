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

struct InlineWidgetView: View {

  @State var date: Date

  var body: some View {
    let shichen = date.shichen
    let keString = "\(NumberFormatter.tranditionalChineseNunmberFormatter.string(from: NSNumber(value: shichen?.currentKe ?? 0)) ?? "")刻"
    
    ViewThatFits(in: .horizontal) {
      Text("\(date.displayStringOfChineseYearMonthDateWithZodiac) \(shichen?.dizhi.displayHourText ?? "")\(keString)")
      Text(shichen?.dizhi.displayHourText ?? "" + keString)
    }
    .font(.body)
    .widgetAccentable()
  }
}

// MARK: - InlineWidgetView_Previews

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
