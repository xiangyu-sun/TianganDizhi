//
//  MainView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import ChineseTranditionalCalendarUI
import os
import SwiftUI
import WidgetKit

private let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.MainView", category: "View")

// MARK: - MainView

struct MainView: View {
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
  @State private var showNewYearCountdown = false

  private func rebuildCachedValues() {
    let converter = useGTM8 ? DayConverter(calendar: .chineseCalendarGTM8) : DayConverter()
    let ev = converter.find(day: .day1, month: .yin, inNextYears: 1).first
      ?? EventModel(date: Date(), name: .day1, dateComponents: .init())
    cachedEvent = ev
    cachedTitle = useGTM8
      ? ev.date.displayStringOfChineseYearMonthDateWithZodiacGTM8
      : ev.date.displayStringOfChineseYearMonthDateWithZodiac
    // New-year proximity gate also scans dates — cache it instead of running every minute in body.
    showNewYearCountdown = converter.nextChineseNewYear()
      .map { converter.isWithinMonths(3, beforeChineseNewYearFrom: $0) } ?? false
  }

  @State private var showingCalendar = false

  var body: some View {
    TimelineView(.everyMinute) { context in
      let date = context.date
      VStack {
        #if os(watchOS)
        WatchMainView(date: date, wetherData: weatherData.forcastedWeather)
        #else
        VStack(spacing: 0) {
          let god = date.twelveGod()
          Button {
            showingCalendar = true
          } label: {
            HStack {
              Text(date.displayStringOfChineseYearMonthDateWithZodiac)
              Text(god.map { "·" + $0.chinese } ?? "")
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .font(titleFont)
          }
          .buttonStyle(.plain)
          .accessibilityLabel("月曆，點擊查看")

          if showNewYearCountdown {
            HStack(spacing: 0) {
              Text(cachedEvent.date, style: .relative)
              Text("後\(cachedTitle)")
            }
            .font(bodyFont)
          }

          if let festival = date.chineseFestival {
            Text(festival.chineseName)
              .font(bodyFont)
              .foregroundStyle(.primary)
              .accessibilityLabel("今日節日：\(festival.chineseName)")
          } else {
            Text(date.jieQiDisplayText)
              .font(bodyFont)
          }

          if let value = weatherData.forcastedWeather {
            SunInformationView(info: value)
          } else {
            if let moonphase = date.chineseDay()?.moonPhase {
              fixedMoonInformationView(moonphase)
            }
            Button("位置資料不可用，點擊重試") {
              refreshLocationAndWeather()
            }
            .font(footnote)
            .foregroundStyle(.secondary)
          }
        }

        if let shichen = date.shichen {
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

        let mansion = LunarMansion.lunarMansion(date: date)
        HStack {
          Text("星象: \(mansion.fourSymbol.rawValue)")
          Text("星宿: \(mansion.rawValue)")
        }
        .foregroundStyle(Color.secondary)
        .font(calloutFont)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("星象：\(mansion.fourSymbol.rawValue)，星宿：\(mansion.rawValue)")

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
              Link("天氣以及日月信息來自( Weather). 點擊查看數據源信息",
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
      .foregroundStyle(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
      #if os(iOS) || os(macOS)
      .materialBackground(with: Image("background"), toogle: springFestiveBackgroundEnabled)
      #endif
      #if os(macOS)
      .frame(minHeight: 640)
      #endif
    }
    .sheet(isPresented: $showingCalendar) {
      #if os(iOS) || os(macOS)
      if #available(iOS 17, macOS 14, *) {
        CalendarSheetView()
      }
      #endif
    }
    .onAppear {
      rebuildCachedValues()
      refreshLocationAndWeather()
    }
    .onChange(of: useGTM8) { _ in
      rebuildCachedValues()
    }
    .onChange(of: scenePhase) { newValue in
      if newValue == .active {
        refreshLocationAndWeather()
      }
    }
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
        logger.error("Location/weather refresh failed: \(error.localizedDescription)")
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

// MARK: - Shichen share text

extension Date {
  /// Human-readable summary of this date's Shichen, festival/Jieqi, lunar mansion and 宜/忌.
  /// Shared by SettingsView's ShareLink (and any future share entry points).
  var shichenShareText: String {
    var lines: [String] = []
    lines.append("日期：\(displayStringOfChineseYearMonthDateWithZodiac)")
    if let shichen = shichen {
      lines.append("時辰：\(shichen.dizhi.aliasName)（\(shichen.dizhi.displayHourText)）")
    }
    if let festival = chineseFestival {
      lines.append("今日：\(festival.chineseName)")
    } else {
      let jieqi = jieQiDisplayText
      if !jieqi.isEmpty { lines.append("節氣：\(jieqi)") }
    }
    let mansion = LunarMansion.lunarMansion(date: self)
    lines.append("星象：\(mansion.fourSymbol.rawValue)·\(mansion.rawValue)")
    if let god = twelveGod() {
      lines.append("宜：\(god.do)")
      lines.append("忌：\(god.dontDo)")
    }
    return lines.joined(separator: "\n")
  }
}

// MARK: - CalendarSheetView

#if os(iOS) || os(macOS)
@available(iOS 17, macOS 14, *)
struct CalendarSheetView: View {
  @State private var viewModel = MonthlyCalendarViewModel()

  var body: some View {
    NavigationStack {
      MonthlyCalendarView(viewModel: viewModel)
        .navigationTitle("月曆")
      #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
      #endif
    }
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
  }
}
#endif

#Preview {
  MainView()
    .environment(\.locale, Locale(identifier: "zh_Hant"))
}

#Preview {
  MainView()
    .environment(\.locale, Locale(identifier: "ja_JP"))
}
