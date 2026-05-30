//
//  MenuBarContentView.swift
//  TianganDizhi
//
//  Enhanced menu bar experience for macOS
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

#if os(macOS)
struct MenuBarContentView: View {
  @ObservedObject var weatherData = WeatherData.shared
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false
  @AppStorage(Constants.displayMoonPhaseOnWidgets, store: Constants.sharedUserDefault)
  var displayMoonPhase = true

  var body: some View {
    TimelineView(.everyMinute) { context in
      let date = context.date
      VStack(spacing: 12) {
        compactClockView(date: date)

        Divider()

        currentShichenInfo(date: date)

        Divider()

        infoSection(date: date)

        Divider()

        quickActions
      }
      .padding()
      .frame(width: 280)
    }
  }

  // MARK: - Compact Clock View

  private func compactClockView(date: Date) -> some View {
    VStack(spacing: 8) {
      if let shichen = date.shichen {
        ZStack {
          Circle()
            .stroke(lineWidth: 2)
            .foregroundStyle(.secondary.opacity(0.3))
            .frame(width: 120, height: 120)

          ForEach(Dizhi.allCases, id: \.self) { dizhi in
            let isCurrent = dizhi == shichen.dizhi
            let angle = Angle(degrees: Double(dizhi.rawValue) * 30 - 90)

            Circle()
              .fill(isCurrent ? Color.accentColor : Color.secondary.opacity(0.4))
              .frame(width: isCurrent ? 12 : 6, height: isCurrent ? 12 : 6)
              .offset(y: -50)
              .rotationEffect(angle)
          }

          VStack(spacing: 2) {
            Text(shichen.dizhi.chineseCharacter)
              .font(.title2.bold())
            Text("\(shichen.currentKeSpellOut)刻")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      }
    }
  }

  // MARK: - Current Shichen Info

  private func currentShichenInfo(date: Date) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      if let shichen = date.shichen {
        HStack {
          Text("時辰")
            .font(.caption)
            .foregroundStyle(.secondary)
          Spacer()
          Text(shichen.dizhi.displayHourText)
            .font(.subheadline)
        }

        HStack {
          Text("別名")
            .font(.caption)
            .foregroundStyle(.secondary)
          Spacer()
          Text(shichen.dizhi.aliasName)
            .font(.subheadline)
        }

        if let god = date.twelveGod() {
          HStack {
            Text("十二神")
              .font(.caption)
              .foregroundStyle(.secondary)
            Spacer()
            Text(god.chinese)
              .font(.subheadline)
          }
        }
      }
    }
  }

  // MARK: - Info Section

  private func infoSection(date: Date) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: "calendar")
          .foregroundStyle(Color.accentColor)
        Text(date.jieQiDisplayText)
          .font(.subheadline)
          .lineLimit(2)
      }

      if displayMoonPhase, let moonphase = date.chineseDay()?.moonPhase {
        HStack {
          Image(systemName: moonphase.moonPhase.symbolName)
            .foregroundStyle(Color.accentColor)
          VStack(alignment: .leading, spacing: 2) {
            Text(moonphase.name(traditionnal: useTranditionalNaming))
              .font(.subheadline)
            if let gua = moonphase.gua {
              Text(gua.description)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
        }
      }

      if let weather = weatherData.forcastedWeather {
        HStack {
          Image(systemName: "cloud.sun")
            .foregroundStyle(Color.accentColor)
          Text(weather.condition)
            .font(.subheadline)
          Spacer()
          Text(MeasurmentFormatterManager.buildTemperatureDescription(high: weather.temperatureHigh, low: weather.temperatureLow))
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
    }
  }

  // MARK: - Quick Actions

  private var quickActions: some View {
    VStack(spacing: 6) {
      Button(action: openMainWindow) {
        HStack {
          Image(systemName: "app.badge")
          Text("打開主視窗")
          Spacer()
          Text("⌘O")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .buttonStyle(.plain)

      Button(action: copyCurrentInfo) {
        HStack {
          Image(systemName: "doc.on.doc")
          Text("複製時辰資訊")
          Spacer()
          Text("⌘C")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .buttonStyle(.plain)

      Button(action: openSettings) {
        HStack {
          Image(systemName: "gearshape")
          Text("設置")
          Spacer()
          Text("⌘,")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .buttonStyle(.plain)

      Divider()

      Button(action: quitApp) {
        HStack {
          Image(systemName: "power")
          Text("退出")
          Spacer()
          Text("⌘Q")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .buttonStyle(.plain)
    }
  }

  // MARK: - Actions

  private func openMainWindow() {
    NSApplication.shared.activate()
    if let window = NSApplication.shared.windows.first(where: { $0.title.contains("TianganDizhi") || $0.isMainWindow }) {
      window.makeKeyAndOrderFront(nil)
    }
  }

  private func copyCurrentInfo() {
    let date = Date()
    let dateInfo = date.displayStringOfChineseYearMonthDateWithZodiac
    let shichenInfo = date.shichen?.dizhi.displayHourText ?? ""
    let godInfo = date.twelveGod()?.chinese ?? ""
    let jieqiInfo = date.jieQiDisplayText

    let fullInfo = """
    日期：\(dateInfo)
    時辰：\(shichenInfo)
    十二神：\(godInfo)
    節氣：\(jieqiInfo)
    """

    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(fullInfo, forType: .string)
  }

  private func openSettings() {
    NSApplication.shared.activate()
    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
  }

  private func quitApp() {
    NSApplication.shared.terminate(nil)
  }
}

#Preview {
  MenuBarContentView()
    .frame(width: 280)
}

#endif
