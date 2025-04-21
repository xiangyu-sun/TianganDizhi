//
//  MainView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - MainView

struct MainView: View {
  @ObservedObject var updater = DateProvider()
  @Environment(\.titleFont) var titleFont
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.shouldScaleFont) var shouldScaleFont
  @StateObject var weatherData = WeatherData.shared
  @Environment(\.scenePhase) var scenePhase
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false

  @AppStorage(Constants.useGTM8, store: Constants.sharedUserDefault)
  var useGTM8 = false
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
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

  var body: some View {
    VStack {
      #if os(watchOS)
      WatchMainView(date: updater.currentDate, wetherData: weatherData.forcastedWeather)
      #else

      VStack {
        Text(updater.currentDate.displayStringOfChineseYearMonthDateWithZodiac)
          .font(titleFont)

        Text(updater.currentDate.jieQiText)
          .font(bodyFont)

        if let value = weatherData.forcastedWeather {
          if horizontalSizeClass == .regular {
            HStack {
              Text(MeasurmentFormatterManager.buildTemperatureDescription(high: value.temperatureHigh, low: value.temperatureLow))
                .font(bodyFont)
                .foregroundColor(Color.secondary)
                .onChange(of: scenePhase) { newValue in
                  switch newValue {
                  case .active:
                    refreshLocationAndWeather()
                  default:
                    break
                  }
                }
              Text("\(value.condition)")
                .font(bodyFont)
                .foregroundColor(Color.secondary)
            }
          } else {
            Text(MeasurmentFormatterManager.buildTemperatureDescription(high: value.temperatureHigh, low: value.temperatureLow))
              .font(bodyFont)
              .foregroundColor(Color.secondary)
              .onChange(of: scenePhase) { newValue in
                switch newValue {
                case .active:
                  refreshLocationAndWeather()
                default:
                  break
                }
              }
            Text("\(value.condition)")
              .font(bodyFont)
              .foregroundColor(Color.secondary)
          }
          withAnimation {
            SunInformationView(info: value)
          }

        } else {
          if let moonphase = updater.currentDate.chineseDay()?.moonPhase {
            fixedMoonInformationView(moonphase)
          }
        }
      }
      .padding([.top, .leading, .trailing])

      if let shichen = updater.currentDate.shichen {
        ZStack {
          #if os(macOS)
          CircularContainerView(currentShichen: shichen.dizhi, padding: 0)
            .frame(minWidth: 640)
          #else
          CircularContainerView(currentShichen: shichen.dizhi, padding: shouldScaleFont ? 0 : -10)
            .fixedSize(horizontal: false, vertical: true)
          #endif

          VStack {
            Text(shichen.dizhi.aliasName)
              .font(largeTitleFont)
            Text(shichen.dizhi.organReference)
              .font(bodyFont)
          }
        }
      }

      Spacer()

      // Moon
      if let value = weatherData.forcastedWeather {
        withAnimation {
          VStack {
            MoonInformationView(info: value)
            Text("天氣以及日月信息來自  Weather. 點擊查看數據源信息")
              .font(footnote)
              .foregroundColor(.secondary)
              .onTapGesture {
                if let url = URL(string: "https://weatherkit.apple.com/legal-attribution.html") {
                  #if os(iOS)
                  UIApplication.shared.open(url, options: [:])
                  #elseif os(macOS)
                  NSWorkspace.shared.open(url)
                  #endif
                }
              }
          }
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
    #endif
      .onAppear {
        refreshLocationAndWeather()
      }

    #if os(macOS)
      .frame(minHeight: 640)
    #endif
  }

  func refreshLocationAndWeather() {
    if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
      Task {
        do {
          let location = try await LocationManager.shared.startLocationUpdate()
          try await self.weatherData.dailyForecast(for: location)

          WidgetCenter.shared.getCurrentConfigurations { result in
            guard case .success(let widgets) = result else { return }

            let validWidgets = widgets.filter { widget in
              let intent = widget.configuration as? ConfigurationIntent
              return intent?.date?.isSameWithCurrentShichen ?? false
            }

            for validWidget in validWidgets {
              WidgetCenter.shared.reloadTimelines(ofKind: validWidget.kind)
            }
          }
        } catch {
          print(error)
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

// MARK: - MainView_Previews

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
      .environment(\.locale, Locale(identifier: "zh_Hant"))
    MainView()
      .environment(\.locale, Locale(identifier: "ja_JP"))
  }
}
