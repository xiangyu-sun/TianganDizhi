//
//  CornerView.swift
//  ShichenWatch Watch App
//
//  Created by Xiangyu Sun on 24/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - CornerView

struct CornerView: View {
  @State var date: Date

  var body: some View {
      let shichen = date.shichen!
      let start = date.timeIntervalSince1970 - shichen.startDate.timeIntervalSince1970

      let base = shichen.endDate.timeIntervalSince1970 - shichen.startDate.timeIntervalSince1970
    ZStack {
      Text(date.chineseDate)
        .font(.largeTitle)
    }
    .widgetLabel {
      Gauge(value: start / base) { } currentValueLabel: { } minimumValueLabel: {
          Text(shichen.startDate.shichen?.dizhi.chineseCharactor ?? "")
          .foregroundColor(.primary)
      } maximumValueLabel: {
          Text(shichen.dizhi.next.chineseCharactor)
          .foregroundColor(.secondary)
      }
    }
  }
}

// MARK: - CornerView_Previews

struct CornerView_Previews: PreviewProvider {
  static var previews: some View {
    CornerView(date: .now)
      .previewContext(WidgetPreviewContext(family: .accessoryCorner))
  }
}
