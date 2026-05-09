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
  @EnvironmentObject var updater: DateProvider
  @Environment(\.titleFont) var titleFont
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.calloutFont) var calloutFont
  @Environment(\.shouldScaleFont) var shouldScaleFont
  @ObservedObject var weatherData = WeatherData.shared
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

  // Cached computed values — rebuilt only when useGTM8 changes or on appear.
  // These are expensive (date scanning), so must NOT live in `body`.
  @State private var cachedEvent: EventModel = .init(date: Date(), name: .day1, dateComponents: .init())
  @State private var cachedTitle: String = ""

  private func rebuildCachedValues() {
    let converter = useGTM8 ? DayConverter(calendar: .chineseCalendarGTM8) : DayConverter()
    let ev = converter.find(day: .day1, month: .yin, inNextYears: 1).first
      ?? EventModel(date: Date(), name: .day1, dateComponents: .init())
    cachedEvent = ev
    cachedTitle = useGTM8
      ? ev.date.displayStringOfChineseYearMonthDateWithZodiacGTM8
      : ev.date.displayStringOfChineseYearMonthDateWithZodiac
  }

  @State private var showingPopover = false

  var body: some View {
    VStack {
      #if os(watchOS)
      WatchMainView(date: updater.currentDate, wetherData: weatherData.forcastedWeather)
      #else
      VStack(spacing: 0) {
        let god = updater.currentDate.twelveGod()
        HStack {
          Text(updater.currentDate.displayStringOfChineseYearMonthDateWithZodiac)
          Text(god.map { "·" + $0.chinese } ?? "")
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .font(titleFont)

        if let nextChineseNewYear = (useGTM8 ? DayConverter(calendar: .chineseCalendarGTM8) : DayConverter()).nextChineseNewYear(),
           (useGTM8 ? DayConverter(calendar: .chineseCalendarGTM8) : DayConverter()).isWithinMonths(3, beforeChineseNewYearFrom: nextChineseNewYear) {
          HStack(spacing: 0) {
            Text(cachedEvent.date, style: .relative)
            Text("後\(cachedTitle)")
          }
          .font(bodyFont)
        }

        if let festival = updater.currentDate.chineseFestival {
          Text(festival.chineseName)
            .font(bodyFont)
            .foregroundStyle(.primary)
            .accessibilityLabel("今日節日：\(festival.chineseName)")
        } else {
          Text(updater.currentDate.jieQiDisplayText)
            .font(bodyFont)
        }

        if let value = weatherData.forcastedWeather {
          SunInformationView(info: value)
        } else {
          if let moonphase = updater.currentDate.chineseDay()?.moonPhase {
            fixedMoonInformationView(moonphase)
          }
        }
      }

      if let shichen = updater.currentDate.shichen {
        ZStack {
          #if os(macOS)
          CircularContainerView(currentShichen: shichen.dizhi, padding: 0)
            .frame(minWidth: 640)
          #else
          if horizontalSizeClass == .compact {
            CircularContainerView(currentShichen: shichen.dizhi, padding: shouldScaleFont ? 0 : -10)
              .fixedSize(horizontal: false, vertical: true)
          } else {
            CircularContainerView(currentShichen: shichen.dizhi, padding: shouldScaleFont ? 0 : -10)
          }
          #endif

          VStack {
            Text("\(shichen.currentKeSpellOut)刻")
              .font(largeTitleFont)
            HStack() {
              Text(shichen.dizhi.aliasName)
              Text(shichen.dizhi.luizhu.organReference)
                .foregroundStyle(shichen.dizhi.luizhu.是表经 ? Color.primary : Color.secondary)
            }
            .font(bodyFont)
          }
          .accessibilityElement(children: .combine)
          .accessibilityLabel("\(shichen.dizhi.aliasName)時，第\(shichen.currentKeSpellOut)刻，\(shichen.dizhi.organReference)")
          .accessibilityAddTraits(.updatesFrequently)
        }
      }

      Spacer()

      // Compute once to avoid duplicate calls every render
      let mansion = LunarMansion.lunarMansion(date: updater.currentDate)
      HStack {
        Text("星象: \(mansion.fourSymbol.rawValue)")
        Text("星宿: \(mansion.rawValue)")
      }
      .foregroundStyle(Color.secondary)
      .font(calloutFont)
      .accessibilityElement(children: .combine)
      .accessibilityLabel("星象：\(mansion.fourSymbol.rawValue)，星宿：\(mansion.rawValue)")

      // Moon / weather detail
      if let value = weatherData.forcastedWeather {
        VStack {
          MoonInformationView(info: value)
          if horizontalSizeClass == .regular {
            HStack {
              Text(MeasurmentFormatterManager.buildTemperatureDescription(high: value.temperatureHigh, low: value.temperatureLow))
                .font(calloutFont)
                .foregroundStyle(Color.secondary)
              Text("\(value.condition)")
                .font(calloutFont)
                .foregroundStyle(Color.secondary)
            }
          } else {
            Text(MeasurmentFormatterManager.buildTemperatureDescription(high: value.temperatureHigh, low: value.temperatureLow))
              .font(calloutFont)
              .foregroundStyle(Color.secondary)
            Text("\(value.condition)")
              .font(calloutFont)
              .foregroundStyle(Color.secondary)
          }

          if let weatherURL = URL(string: "https://weatherkit.apple.com/legal-attribution.html") {
            Link("天氣以及日月信息來自  Weather. 點擊查看數據源信息",
                 destination: weatherURL)
            .font(footnote)
            .foregroundStyle(.secondary)
          }
        }
        .padding(.bottom)
      }

      #endif
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    #if os(iOS) || os(macOS)
    .popover(isPresented: $showingPopover, arrowEdge: .bottom) {
      VStack(alignment: .leading) {
        let god = updater.currentDate.twelveGod()
        Text("宜：\(god.map { $0.do } ?? "")")
          .font(titleFont)
          .padding(.bottom)
        Text("忌：\(god.map { $0.dontDo } ?? "")")
          .font(titleFont)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(
        Image("background")
          .resizable(resizingMode: .tile)
          .scaledToFill()
          .ignoresSafeArea(.all)
      )
    }
    #endif
    .foregroundStyle(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
    #if os(iOS) || os(macOS)
    .materialBackground(with: Image("background"), toogle: springFestiveBackgroundEnabled)
    #endif
    .onAppear {
      rebuildCachedValues()
      refreshLocationAndWeather()
    }
    .onChange(of: useGTM8) { _ in
      rebuildCachedValues()
    }
    // Consolidated single scenePhase handler (was duplicated inside if/else branches)
    .onChange(of: scenePhase) { newValue in
      if newValue == .active {
        refreshLocationAndWeather()
      }
    }
    #if os(macOS)
    .frame(minHeight: 640)
    #endif
  }

  func refreshLocationAndWeather() {
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

  func fixedMoonInformationView(_ moonphase: ChineseMoonPhase) -> some View {
    HStack {
      Image(systemName: moonphase.moonPhase.symbolName)
      Text(moonphase.name(traditionnal: useTranditionalNaming))
      if let gua = moonphase.gua {
        Text(gua.description)
      }
    }
    .font(bodyFont)
  }
}

#Preview {
  MainView()
    .environment(\.locale, Locale(identifier: "zh_Hant"))
}

#Preview {
  MainView()
    .environment(\.locale, Locale(identifier: "ja_JP"))
}
