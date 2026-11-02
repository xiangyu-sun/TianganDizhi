//
//  WatchMainView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/2/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - WatchMainView

struct WatchMainView: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let date: Date
  let wetherData: WeatherData.Information?
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false
  @Environment(\.titleFont) var titleFont
  @Environment(\.footnote) var footnote

  var body: some View {
    Group {
      HStack {
        Text(date.compactLunarDate(language: displayLanguage))
          .englishFit(displayLanguage, lines: 2, minimumScale: 0.6)
        if let value = wetherData {
          Image(systemName: value.moonPhase.moonPhase.symbolName)
          Text(value.moonPhase.name(traditionnal: true, language: displayLanguage))
        } else if let moonPhase = date.chineseDay()?.moonPhase {
          Image(systemName: moonPhase.moonPhase.symbolName)
          Text(moonPhase.name(traditionnal: useTranditionalNaming, language: displayLanguage))
        }
      }
      if let shichen = date.shichen {
        CircularContainerView(currentShichen: shichen.dizhi, padding: -24) {
          VStack {
            Text(shichen.dizhi.aliasName.converted(to: displayLanguage))
              .font(titleFont)
            Text(shichen.dizhi.luizhu.organText(in: displayLanguage))
              .font(footnote)
          }
        }
      }
    }
  }
}

#Preview {
  WatchMainView(
    date: .now,
    wetherData: WeatherData
      .Information(
        moonPhase: .firstQuarter,
        moonRise: Date(),
        moonset: Date(),
        sunrise: Date(),
        sunset: Date(),
        noon: Date(),
        midnight: Date(),
        temperatureHigh: .init(value: 1, unit: .celsius),
        temperatureLow: .init(value: 1, unit: .celsius),
        condition: ""
      )
  )
}
