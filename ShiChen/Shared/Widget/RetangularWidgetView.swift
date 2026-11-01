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
        return jieqi.localizedName(in: DisplayLanguage.app.glyphLanguage)
      }
    }
    return nil
  }
}

struct RetangularWidgetView: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let date: Date
  
  var god: String {
    date.twelveGod().map { "·" + $0.localizedName(in: displayLanguage.glyphLanguage) } ?? ""
  }

  var body: some View {
    let shichen = date.shichen

    HStack {
     
      Text(date.lunarDateWithZodiac(language: displayLanguage) + (date.nextJieJiWithinOneDay.map { "·" + $0 } ?? "") + god)
        .font(.body)
      
      VStack() {
        Text(shichen?.dizhi.localizedHourName(in: displayLanguage.glyphLanguage) ?? "" )
        //Text("\(NumberFormatter.tranditionalChineseNunmberFormatter.string(from: NSNumber(value: shichen?.currentKe ?? 0)) ?? "")刻")
      }
        .font(.headline)
    }
    .widgetAccentable()
  }
}

#Preview {
  RetangularWidgetView(date: .now)
}
