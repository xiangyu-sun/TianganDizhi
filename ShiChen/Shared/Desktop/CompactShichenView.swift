//
//  CompactShichenView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/16/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WeatherKit
import WidgetKit

// MARK: - CompactShichenView

struct CompactShichenView: View {

  // MARK: Internal

  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.title3Font) var title3Font

  let shichen: Dizhi
  let date: Date

  var body: some View {
    VStack {
      titleView
      Text(shichen.displayHourText)
        .font(largeTitleFont)

      ShichenInformationView(shichen: shichen)
    }
  }
  
  var components: DateComponents {
    date.dateComponentsFromChineseCalendar()
  }

  // MARK: Private

  private var titleView: some View {
    
    HStack {
      Text(components.nian?.formatedYear ?? "")
      Text(components.zodiac?.rawValue ?? "")
    }
    .font(title3Font)
  }
}

#if os(iOS)
struct CompactShichenView_Previews: PreviewProvider {
  static var previews: some View {
    CompactShichenView(shichen: .zi, date: Date())
      .previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}
#endif
