//
//  CircularWidgetView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 26/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - CircularWidgetView

@available(iOS 16.0, *)
struct CircularWidgetView: View {

  @State var date: Date

  var body: some View {
    if let shichen = date.shichen {
      let start = date.timeIntervalSince1970 - shichen.startDate.timeIntervalSince1970

      let base = shichen.endDate.timeIntervalSince1970 - shichen.startDate.timeIntervalSince1970

      ProgressView(
        value: start / base,
        label: {
          Text(shichen.dizhi.displayHourText)
            .widgetAccentable()
        },
        currentValueLabel: {
          Text(shichen.dizhi.displayHourText)
            .widgetAccentable()
          #if os(iOS)
            .font(.body)
          #endif
        })
        .widgetAccentable()
        .progressViewStyle(.circular)
    } else {
      EmptyView()
    }
  }
}

// MARK: - CircularWidgetView_Previews

@available(iOS 16.0, *)
struct CircularWidgetView_Previews: PreviewProvider {
  static var previews: some View {
    #if os(macOS)
    CircularWidgetView(date: .now)
      .previewContext(WidgetPreviewContext(family: .systemLarge))
    #else
    CircularWidgetView(date: .now)
      .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    #endif
  }
}
