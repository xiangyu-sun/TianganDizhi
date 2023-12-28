//
//  WatchMainView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/2/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

// MARK: - WatchMainView

struct WatchMainView: View {
  @State var date: Date
  @State var wetherData: WeatherData.Information?
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false
  var body: some View {
    Group {
      HStack {
        Text(date.displayStringOfChineseYearMonthDateWithZodiac)
        if let value = wetherData {
          Text(value.moonPhase.name(traditionnal: true))
        } else {
          Text(date.chineseDay()?.moonPhase.name(traditionnal: useTranditionalNaming) ?? "")
        }
      }
      if let shichen = date.shichen {
        CircularContainerView(currentShichen: shichen.dizhi, padding: -24)
      }
    }
  }
}

// MARK: - WatchMainView_Previews

@available(iOS 15, *)
struct WatchMainView_Previews: PreviewProvider {
  static var previews: some View {
    WatchMainView(date: .now)
  }
}
