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
  @AppStorage("springFestiveBackgroundEnabled") var springFestiveBackgroundEnabled: Bool = false
  var body: some View {
    VStack {
      let shichen = try! GanzhiDateConverter.shichen(updater.currentDate)
      
#if os(watchOS)
      HStack {
        Text((try? GanzhiDateConverter.zodiac(updater.currentDate).rawValue) ?? "")
        Text(updater.currentDate.displayStringOfChineseYearMonthDateWithZodiac)
        if let value = weatherData.forcastedWeather {
          Text(value.moonPhaseDisplayName)
            .font(titleFont)
        }else {
          Text(updater.currentDate.chineseDay?.moonPhase.rawValue ?? "")
            .font(bodyFont)
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
          }else {
            Text(updater.currentDate.chineseDay?.moonPhase.rawValue ?? "")
              .font(bodyFont)
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
#if os(iOS)
    .materialBackground(with:  Image("background"), toogle: springFestiveBackgroundEnabled)
    .onAppear(){
      if #available(iOS 16.0, *) {
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
