//
//  MediumWidgetView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 7/4/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import SwiftUI
import WidgetKit

// MARK: - MediumWidgetView

struct MediumWidgetView: View {
  let date: Date

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false
  @Environment(\.title3Font) var title3Font
  @Environment(\.footnote) var footnote
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false

  #if os(iOS) || os(macOS)
  @StateObject var weatherData = WeatherData.shared
  #endif

  var body: some View {
    VStack {
      Spacer(minLength: 8)
      FullDateTitleView(date: date)
          .font(title3Font)
  
      #if os(iOS) || os(macOS)
      Spacer(minLength: 4)
      if let value = weatherData.forcastedWeather {
        Text(
          MeasurmentFormatterManager
            .buildTemperatureDescription(high: value.temperatureHigh, low: value.temperatureLow) + "\(value.condition)")
          .font(footnote)
          .foregroundColor(Color.secondary)
      }
      Spacer(minLength: 4)
      #else
      Spacer()
      #endif
      if let shichen = date.shichen {
        ShichenHStackView(shichen: shichen.dizhi)
          .padding([.leading, .trailing], 8)
      }
      Spacer()
    }
    .modifier(WidgetAccentable())
    .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
    .materialBackgroundWidget(with: Image("background"), toogle: springFestiveBackgroundEnabled)
    #if os(iOS) || os(macOS)
    .onAppear {
      if #available(iOS 16.0, macOS 13.0, *) {
        Task {
          do {
            if let location = LocationManager.shared.lastLocation {
              try await self.weatherData.dailyForecast(for: location)
            } else {
              let location = try await LocationManager.shared.startLocationUpdate()
              try await self.weatherData.dailyForecast(for: location)
            }
          } catch {
            print(error)
          }
        }
      }
    }
    #endif
  }
}

#if !os(watchOS)

struct MediumWidgetView_Previews: PreviewProvider {
  static var previews: some View {
    MediumWidgetView(date: Date())
      .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
#endif
