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
  @ObservedObject var updater: DateProvider
  @StateObject var weatherData = WeatherData.shared
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false
  @AppStorage(Constants.displayMoonPhaseOnWidgets, store: Constants.sharedUserDefault)
  var displayMoonPhase = true
  
  var body: some View {
    VStack(spacing: 12) {
      // Compact Circular Clock
      compactClockView
      
      Divider()
      
      // Current Shichen Info
      currentShichenInfo
      
      Divider()
      
      // Jieqi and Moon Phase
      infoSection
      
      Divider()
      
      // Quick Actions
      quickActions
    }
    .padding()
    .frame(width: 280)
  }
  
  // MARK: - Compact Clock View
  
  private var compactClockView: some View {
    VStack(spacing: 8) {
      if let shichen = updater.currentDate.shichen {
        ZStack {
          // Miniature circular clock
          Circle()
            .stroke(lineWidth: 2)
            .foregroundColor(.secondary.opacity(0.3))
            .frame(width: 120, height: 120)
          
          // Simplified Shichen indicators
          ForEach(Dizhi.allCases, id: \.self) { dizhi in
            let isCurrent = dizhi == shichen.dizhi
            let angle = Angle(degrees: Double(dizhi.rawValue) * 30 - 90)
            
            Circle()
              .fill(isCurrent ? Color.accentColor : Color.secondary.opacity(0.4))
              .frame(width: isCurrent ? 12 : 6, height: isCurrent ? 12 : 6)
              .offset(y: -50)
              .rotationEffect(angle)
          }
          
          // Center text
          VStack(spacing: 2) {
            Text(shichen.dizhi.chineseCharacter)
              .font(.title2.bold())
            Text("\(shichen.currentKeSpellOut)刻")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      }
    }
  }
  
  // MARK: - Current Shichen Info
  
  private var currentShichenInfo: some View {
    VStack(alignment: .leading, spacing: 4) {
      if let shichen = updater.currentDate.shichen {
        HStack {
          Text("時辰")
            .font(.caption)
            .foregroundColor(.secondary)
          Spacer()
          Text(shichen.dizhi.displayHourText)
            .font(.subheadline)
        }
        
        HStack {
          Text("別名")
            .font(.caption)
            .foregroundColor(.secondary)
          Spacer()
          Text(shichen.dizhi.aliasName)
            .font(.subheadline)
        }
        
        if let god = updater.currentDate.twelveGod() {
          HStack {
            Text("十二神")
              .font(.caption)
              .foregroundColor(.secondary)
            Spacer()
            Text(god.chinese)
              .font(.subheadline)
          }
        }
      }
    }
  }
  
  // MARK: - Info Section
  
  private var infoSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      // Jieqi
      HStack {
        Image(systemName: "calendar")
          .foregroundColor(.accentColor)
        Text(updater.currentDate.jieQiDisplayText)
          .font(.subheadline)
          .lineLimit(2)
      }
      
      // Moon Phase
      if displayMoonPhase, let moonphase = updater.currentDate.chineseDay()?.moonPhase {
        HStack {
          Image(systemName: moonphase.moonPhase.symbolName)
            .foregroundColor(.accentColor)
          VStack(alignment: .leading, spacing: 2) {
            Text(moonphase.name(traditionnal: useTranditionalNaming))
              .font(.subheadline)
            if let gua = moonphase.gua {
              Text(gua.description)
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
        }
      }
      
      // Weather if available
      if let weather = weatherData.forcastedWeather {
        HStack {
          Image(systemName: "cloud.sun")
            .foregroundColor(.accentColor)
          Text(weather.condition)
            .font(.subheadline)
          Spacer()
          Text(MeasurmentFormatterManager.buildTemperatureDescription(high: weather.temperatureHigh, low: weather.temperatureLow))
            .font(.caption)
            .foregroundColor(.secondary)
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
            .foregroundColor(.secondary)
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
            .foregroundColor(.secondary)
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
            .foregroundColor(.secondary)
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
            .foregroundColor(.secondary)
        }
      }
      .buttonStyle(.plain)
    }
  }
  
  // MARK: - Actions
  
  private func openMainWindow() {
    NSApplication.shared.activate(ignoringOtherApps: true)
    // Find and bring the main window to front
    if let window = NSApplication.shared.windows.first(where: { $0.title.contains("TianganDizhi") || $0.isMainWindow }) {
      window.makeKeyAndOrderFront(nil)
    }
  }
  
  private func copyCurrentInfo() {
    let dateInfo = updater.currentDate.displayStringOfChineseYearMonthDateWithZodiac
    let shichenInfo = updater.currentDate.shichen?.dizhi.displayHourText ?? ""
    let godInfo = updater.currentDate.twelveGod()?.chinese ?? ""
    let jieqiInfo = updater.currentDate.jieQiDisplayText
    
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
    openMainWindow()
    // Post notification to switch to settings tab
    NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
  }
  
  private func quitApp() {
    NSApplication.shared.terminate(nil)
  }
}

// MARK: - Preview

struct MenuBarContentView_Previews: PreviewProvider {
  static var previews: some View {
    MenuBarContentView(updater: DateProvider())
      .frame(width: 280)
  }
}

#endif
