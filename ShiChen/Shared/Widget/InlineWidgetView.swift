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
  @Environment(\.displayLanguage) private var displayLanguage

  let date: Date

  var body: some View {
    let shichen = date.shichen
//    let keString = "\(NumberFormatter.tranditionalChineseNunmberFormatter.string(from: NSNumber(value: shichen?.currentKe ?? 0)) ?? "")刻"
//    
    ViewThatFits(in: .horizontal) {
      Text("\(date.compactLunarDate(language: displayLanguage)) \(shichen?.dizhi.localizedHourName(in: displayLanguage) ?? "")")
      Text(shichen?.dizhi.localizedHourName(in: displayLanguage) ?? "")
    }
    .font(.body)
    .widgetAccentable()
  }
}

#Preview {
  InlineWidgetView(date: .now)
}
