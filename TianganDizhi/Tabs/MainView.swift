//
//  MainView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - MainView

struct MainView: View {
  @ObservedObject var updater = DateProvider()
  @Environment(\.titleFont) var titleFont
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.shouldScaleFont) var shouldScaleFont
  @StateObject var weatherData = WeatherData.shared
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false

  @AppStorage(Constants.useGTM8, store: Constants.sharedUserDefault)
  var useGTM8 = false

  var dayConverter: DayConverter {
    useGTM8 ? DayConverter(calendar: .chineseCalendarGTM8) : DayConverter()
  }

  var event: EventModel {
    dayConverter.find(day: .chuyi, month: .yin, inNextYears: 1).first ??
      .init(date: Date(), name: .chuyi, dateComponents: .init())
  }

  var title: String {
    useGTM8
      ? event.date.displayStringOfChineseYearMonthDateWithZodiacGTM8
      : event.date.displayStringOfChineseYearMonthDateWithZodiac
  }

  func fixedMoonInformationView(_ moonphase: ChineseMoonPhase) -> some View {
    HStack {
      if #available(iOS 16.0, watchOS 9.0, *) {
        Image(systemName: moonphase.moonPhase.symbolName)
      }
      Text(moonphase.name(traditionnal: useTranditionalNaming))
    }
    .font(bodyFont)
  }
  
  
  var body: some View {
    VStack {
      let shichen = updater.currentDate.shichen!

      #if os(watchOS)
      WatchMainView(date: updater.currentDate, wetherData: weatherData.forcastedWeather)
      #else
      
      VStack() {
        Text(updater.currentDate.displayStringOfChineseYearMonthDateWithZodiac)
          .font(titleFont)
        
        if let value = weatherData.forcastedWeather {
          Text(MeasurmentFormatterManager.buildTemperatureDescription(high: value.temperatureHigh, low: value.temperatureLow))
            .font(bodyFont)
            .foregroundColor(Color.secondary)
          Text("天氣\(value.condition)")
            .font(bodyFont)
            .foregroundColor(Color.secondary)
          withAnimation {
            SunInformationView(info: value)
          }
          
        } else {
          if let moonphase = updater.currentDate.chineseDay()?.moonPhase {
            fixedMoonInformationView(moonphase)
          }
        }
      }
      .padding()
      

      ZStack() {
#if os(macOS)
        CircularContainerView(currentShichen: shichen.dizhi, padding: 0)
          .frame(minWidth: 640)
#else
        CircularContainerView(currentShichen: shichen.dizhi, padding: shouldScaleFont ? 0 : -10)
          .fixedSize(horizontal: false, vertical: true)
#endif
        VStack() {
          Text(shichen.dizhi.aliasName)
            .font(largeTitleFont)
          Text(shichen.dizhi.organReference)
            .font(bodyFont)
        }
      }
      
      Spacer()
      
      // Moon
      if let value = weatherData.forcastedWeather {
        withAnimation {
          MoonInformationView(info: value)
            .padding(.bottom)
        }
      }

//      HStack(spacing: 0) {
//        Text(event.date, style: .relative)
//        Text("後\(title)")
//      }
//      .font(bodyFont)
      
      #endif
    }
    .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
    #if os(iOS) || os(macOS)
      .materialBackground(with: Image("background"), toogle: springFestiveBackgroundEnabled)
      .onAppear {
        if #available(iOS 16.0, macOS 13.0, *) {
          Task {
            do {
              let location = try await LocationManager.shared.startLocationUpdate()
              try await self.weatherData.dailyForecast(for: location)
            } catch {
              print(error)
            }
          }
        }
      }
#endif
    #if os(macOS)
.frame(minHeight: 640)
    #endif
  }
}

// MARK: - MainView_Previews

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
      .environment(\.locale, Locale(identifier: "zh_Hant"))
    MainView()
      .environment(\.locale, Locale(identifier: "ja_JP"))
  }
}
