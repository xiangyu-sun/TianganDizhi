//
//  MainView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import ChineseTranditionalCalendarUI
import JingluoShuxue
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
  @Environment(\.displayLanguage) var displayLanguage
  @Environment(\.openURL) var openURL
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
      ? ev.date.lunarDateWithZodiacGTM8(language: displayLanguage)
      : ev.date.lunarDateWithZodiac(language: displayLanguage)
    showNewYearCountdown = converter.nextChineseNewYear()
      .map { converter.isWithinMonths(3, beforeChineseNewYearFrom: $0) } ?? false
  }

  @State private var showingCalendar = false

  #if os(iOS)
  /// Below this height the clock's ring is too small for its twelve glyphs, which
  /// pile up in the middle. The screen scrolls instead of squeezing the clock;
  /// macOS enforces the same floor with `minHeight` on the content.
  private static let minimumContentHeight: CGFloat = 600
  #endif

  var body: some View {
    #if os(iOS)
    // A scene can be any height — a Stage Manager window, Split View — so the
    // content takes the full height when there is room and scrolls when there isn't.
    GeometryReader { proxy in
      ScrollView {
        content
          .frame(width: proxy.size.width, height: max(proxy.size.height, Self.minimumContentHeight))
      }
      .scrollBounceBehavior(.basedOnSize)
    }
    .background { TexturedBackground() }
    #else
    content
    #endif
  }

  private var content: some View {
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
              if displayLanguage.isChinese {
                Text(date.lunarDateWithZodiac(language: displayLanguage))
                Text(god.map { "·" + $0.localizedName(in: displayLanguage) } ?? "")
              } else {
                // One text, so the whole line wraps and shrinks together.
                Text(date.lunarDateWithZodiac(language: displayLanguage) + (god.map { " · " + $0.localizedName(in: displayLanguage) } ?? ""))
              }
            }
            // English names are several times longer than the glyphs.
            .lineLimit(displayLanguage.isChinese ? 1 : 2)
            .minimumScaleFactor(displayLanguage.isChinese ? 0.8 : 0.35)
            .multilineTextAlignment(.center)
            .padding(.horizontal, displayLanguage.isChinese ? 0 : 8)
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

          if let festival = date.chineseFestival(timeZone: .solarTerm) {
            Text(festival.localizedName(in: displayLanguage))
              .font(bodyFont)
              .foregroundStyle(.primary)
              .accessibilityLabel("今日節日：\(festival.localizedName(in: displayLanguage))")
          } else {
            Text(date.jieQiDisplayText(language: displayLanguage))
              .font(bodyFont)
          }

          ForEach(SpecialDayCatalog.customHolidays(on: date), id: \.name) { holiday in
            Text(holiday.name)
              .font(bodyFont)
              .foregroundStyle(.orange)
              .accessibilityLabel("今日自訂節日：\(holiday.name)")
          }

          if let value = weatherData.forcastedWeather {
            SunInformationView(info: value)
          } else {
            if let moonphase = date.chineseDay()?.moonPhase {
              fixedMoonInformationView(moonphase)
            }
            VStack(spacing: 6) {
              Text("開啟定位以顯示天氣與日出日落")
                .font(footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
              Button("點擊重試") {
                refreshLocationAndWeather()
              }
              .font(footnote)
              .foregroundStyle(.secondary)
              #if os(iOS)
              Button("前往設置") {
                if let url = URL(string: "app-settings:") {
                  openURL(url)
                }
              }
              .font(footnote)
              .foregroundStyle(.secondary)
              #endif
            }
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
              Text(shichen.keText(language: displayLanguage))
                .font(largeTitleFont)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
              if displayLanguage.isChinese {
                HStack() {
                  Text(shichen.dizhi.aliasName.converted(to: displayLanguage))
                  Text(shichen.dizhi.luizhu.organReference.converted(to: displayLanguage))
                    .foregroundStyle(shichen.dizhi.luizhu.是表经 ? Color.primary : Color.secondary)
                }
                .font(bodyFont)
              } else {
                // The alias (夜半) is Chinese-only prose; the organ has an English name.
                VStack(spacing: 0) {
                  Text(shichen.dizhi.aliasName)
                  Text(shichen.dizhi.luizhu.organText(in: displayLanguage))
                    .font(footnote)
                    .foregroundStyle(shichen.dizhi.luizhu.是表经 ? Color.primary : Color.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                }
                .font(bodyFont)
              }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(shichenAccessibilityLabel(shichen))
            .accessibilityAddTraits(.updatesFrequently)
          }
        }

        Spacer()

        let mansion = LunarMansion.lunarMansion(date: date)
        HStack {
          Text("星象: \(mansion.fourSymbol.localizedName(in: displayLanguage))")
          Text("星宿: \(mansion.shortName(in: displayLanguage))")
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .foregroundStyle(Color.secondary)
        .font(calloutFont)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("星象：\(mansion.fourSymbol.localizedName(in: displayLanguage))，星宿：\(mansion.shortName(in: displayLanguage))")

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
              Link(destination: weatherURL) {
                Text("天氣以及日月信息來自(")
                  + Text(Image(systemName: "apple.logo"))
                  + Text(" Weather). 點擊查看數據源信息")
              }
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
      #if os(macOS)
      .background { TexturedBackground() }
      .frame(minHeight: 640)
      #endif
    }
    .sheet(isPresented: $showingCalendar) {
      #if os(iOS) || os(macOS)
      CalendarSheetView()
      #endif
    }
    .onAppear {
      rebuildCachedValues()
      refreshLocationAndWeather()
    }
    .onChange(of: useGTM8) { _, _ in
      rebuildCachedValues()
    }
    .onChange(of: scenePhase) { _, newValue in
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

        // Only the 時辰 widget (medium / extra-large) shows weather, and it
        // reads the forecast the app just cached — reload it so it picks that
        // up. This used to filter on the intent's `date`, which nothing sets,
        // so it matched no widgets and weather never reached a widget.
        #if !os(watchOS)
        WidgetCenter.shared.reloadTimelines(ofKind: "ShiChen")
        #endif
      } catch {
        logger.error("Location/weather refresh failed: \(error.localizedDescription)")
      }
    }
  }

  /// The clock centre's spoken label: alias, ke and organ.
  private func shichenAccessibilityLabel(_ shichen: Shichen) -> String {
    let alias = shichen.dizhi.aliasName.converted(to: displayLanguage)
    if displayLanguage.isChinese {
      let organ = shichen.dizhi.luizhu.organReference.converted(to: displayLanguage)
      return "\(alias)，第\(shichen.currentKeSpellOut)刻，\(organ)"
    }
    return [alias, shichen.keText(language: displayLanguage), shichen.dizhi.luizhu.organText(in: displayLanguage)].joined(separator: ", ")
  }

  func fixedMoonInformationView(_ moonphase: ChineseMoonPhase) -> some View {
    HStack {
      Image(systemName: moonphase.moonPhase.symbolName)
      Text(moonphase.name(traditionnal: useTranditionalNaming, language: displayLanguage))
      if let gua = moonphase.gua {
        Text(gua.description(in: displayLanguage))
      }
    }
    .font(bodyFont)
  }

}

// MARK: - Shichen share text

extension Date {
  /// Human-readable summary of this date's Shichen, festival/Jieqi, lunar mansion and 宜/忌.
  var shichenShareText: String {
    shichenShareText(language: .app)
  }

  /// ``shichenShareText`` in `language`. Outside Chinese the names are English;
  /// the alias and 宜/忌 lines are library prose and stay Chinese.
  func shichenShareText(language: DisplayLanguage) -> String {
    var lines: [String] = []
    let bundle = language.localizationBundle
    lines.append(String(localized: "日期：\(lunarDateWithZodiac(language: language))", bundle: bundle, comment: "Share text line"))
    if let shichen = shichen {
      lines.append(String(localized: "時辰：\(shichen.dizhi.aliasName.converted(to: language))（\(shichen.dizhi.localizedHourName(in: language))）", bundle: bundle, comment: "Share text line"))
    }
    if let festival = chineseFestival(timeZone: .solarTerm) {
      lines.append(String(localized: "今日：\(festival.localizedName(in: language))", bundle: bundle, comment: "Share text line"))
    } else {
      let jieqi = jieQiDisplayText(language: language)
      if !jieqi.isEmpty { lines.append(String(localized: "節氣：\(jieqi)", bundle: bundle, comment: "Share text line")) }
    }
    for holiday in SpecialDayCatalog.customHolidays(on: self) {
      lines.append(String(localized: "自訂：\(holiday.name)", bundle: bundle, comment: "Share text line"))
    }
    let mansion = LunarMansion.lunarMansion(date: self)
    lines.append(String(localized: "星象：\(mansion.fourSymbol.localizedName(in: language))·\(mansion.shortName(in: language))", bundle: bundle, comment: "Share text line"))
    if let god = twelveGod() {
      lines.append(String(localized: "宜：\(god.do.converted(to: language))", bundle: bundle, comment: "Share text line"))
      lines.append(String(localized: "忌：\(god.dontDo.converted(to: language))", bundle: bundle, comment: "Share text line"))
    }
    return lines.joined(separator: "\n")
  }
}

// MARK: - CalendarSheetView

#if os(iOS) || os(macOS)
@available(iOS 17, macOS 14, *)
struct CalendarSheetView: View {
  @State private var viewModel = MonthlyCalendarViewModel(
    configuration: CalendarConfiguration(
      specialDaySources: SpecialDayCatalog.sources(language: .app),
      specialDayTimeZone: .solarTerm))

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
    .environment(\.calendarLanguage, displayLanguage)
  }

  @Environment(\.displayLanguage) private var displayLanguage
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
