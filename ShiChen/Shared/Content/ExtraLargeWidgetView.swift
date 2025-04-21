//
//  ExtraLargeWidgetView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 7/4/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - ExtraLargeWidgetView

struct ExtraLargeWidgetView: View {
  let date: Date

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false
  @Environment(\.titleFont) var titleFont
  @Environment(\.bodyFont) var bodyFont
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false

  @StateObject var weatherData = WeatherData.shared

  var body: some View {
    HStack {
      VStack {
        FullDateTitleView(date: date)
          .font(titleFont)
        Spacer(minLength: 4)
        
        Text(date.jieQiText)
          .font(bodyFont)
        
        if let value = weatherData.forcastedWeather {
          MoonInformationView(info: value)
          Text(
            MeasurmentFormatterManager.buildTemperatureDescription(high: value.temperatureHigh, low: value.temperatureLow))
            .font(bodyFont)
            .foregroundColor(Color.secondary)
          Text("\(value.condition)")
            .font(bodyFont)
            .foregroundColor(Color.secondary)
        } else {
          // default
          if let moonphase = date.chineseDay()?.moonPhase {
            fixedMoonInformationView(moonphase)
          }
        }
        if let shichen = date.shichen {
          Spacer(minLength: 4)
          ShichenHStackView(shichen: shichen.dizhi)
            .padding([.top])
        }
        Spacer()
      }
      .padding([.leading, .top, .bottom])

      if let shichen = date.shichen {
        ZStack {
          CircularContainerView(currentShichen: shichen.dizhi, padding: -20)
            .padding()
        }
      }
    }
    .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .materialBackgroundWidget(with: Image("background"), toogle: springFestiveBackgroundEnabled)
    .onAppear {
      if #available(iOS 16.0, *) {
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
  }

  func fixedMoonInformationView(_ moonphase: ChineseMoonPhase) -> some View {
    HStack {
      if #available(iOS 16.0, watchOS 9.0, *) {
        Image(systemName: moonphase.moonPhase.symbolName)
      }
      Text(moonphase.name(traditionnal: useTranditionalNaming))
      if let gua = moonphase.gua {
        Text(gua.description)
      }
    }
    .font(bodyFont)
  }
}

#if os(iOS)
@available(iOSApplicationExtension 15.0, *)
struct ExtraLargeWidgetView_Previews: PreviewProvider {

  static var previews: some View {
    ExtraLargeWidgetView(date: Date())
      .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
      .previewDisplayName("systemExtraLarge")
  }
}
#endif
