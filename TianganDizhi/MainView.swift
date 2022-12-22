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

  var body: some View {
    VStack {
      let shichen = try! GanzhiDateConverter.shichen(updater.currentDate)

      #if os(watchOS)
      HStack {
        Text(updater.currentDate.displayStringOfChineseYearMonthDateWithZodiac)
        if let value = weatherData.forcastedWeather {
          Text(value.moonPhaseDisplayName)
        } else {
          Text(updater.currentDate.chineseDay?.moonPhase.rawValue ?? "")
        }
      }

      CircularContainerView(currentShichen: shichen, padding: -24)

      #else

      HStack {
        VStack(alignment: .leading) {
          Text(updater.currentDate.displayStringOfChineseYearMonthDateWithZodiac)
            .font(titleFont)

          if let value = weatherData.forcastedWeather {
            Text(value.moonPhaseDisplayName)
              .font(titleFont)
          } else {
            if let moonphase = updater.currentDate.chineseDay?.moonPhase {
              HStack {
                if #available(iOS 16.0, *) {
                  Image(systemName: moonphase.moonPhase.symbolName)
                }
                Text(moonphase.rawValue)
              }
              .font(bodyFont)
            }
          }
        }
        .padding(.leading)

        Spacer()
      }

      Text(shichen.aliasName)
        .font(largeTitleFont)
      Text(shichen.organReference)
        .font(bodyFont)

      #if os(macOS)
      CircularContainerView(currentShichen: shichen, padding: 0)
        .frame(minWidth: 640)
      #else
      if shouldScaleFont {
        CircularContainerView(currentShichen: shichen, padding: 0)
      } else {
        CircularContainerView(currentShichen: shichen, padding: -10)
          .fixedSize(horizontal: false, vertical: true)
          .padding()
      }
      #endif
      Spacer()

      #endif
    }
    .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
    #if os(iOS)
      .materialBackground(with: Image("background"), toogle: springFestiveBackgroundEnabled)
//      .onAppear {
//        if #available(iOS 16.0, *) {
//          Task {
//            do {
//              let location = try await LocationManager.shared.startLocationUpdate()
//              try await self.weatherData.dailyForecast(for: location)
//            } catch {
//              print(error)
//            }
//          }
//        }
//      }

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
