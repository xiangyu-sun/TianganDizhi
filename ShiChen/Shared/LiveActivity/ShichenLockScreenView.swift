//
//  ShichenLockScreenView.swift
//  TianganDizhi
//
//  Created by Claude Code
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import SwiftUI
import WidgetKit
import ChineseAstrologyCalendar

// MARK: - ShichenLockScreenView

struct ShichenLockScreenView: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let date: Date
  let nextShichenCountdown: String
  
  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false
  @AppStorage(Constants.displayMoonPhaseOnWidgets, store: Constants.sharedUserDefault)
  var displayMoonPhaseOnWidgets = false
  @Environment(\.title2Font) var title2Font
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.calloutFont) var calloutFont
  
  var body: some View {
    VStack() {
      Spacer(minLength: 4)
      if let shichen = date.shichen {
        // Current Shichen display
        HStack(alignment: .top) {
          Text(date.lunarDateWithZodiac(language: displayLanguage))
            .font(title2Font)
            .englishFit(displayLanguage, lines: 3, minimumScale: 0.6)
          
          VStack() {
            Text(shichen.dizhi.localizedHourName(in: displayLanguage))
              .font(title2Font)
            
            Text(shichen.keText(language: displayLanguage))
              .font(title2Font)
          }
        }
        
        // Countdown to next Shichen
        if !nextShichenCountdown.isEmpty {
          Text(nextShichenCountdown)
            .font(calloutFont)
            .foregroundStyle(.secondary)
            .englishFit(displayLanguage, lines: 2, minimumScale: 0.7)
        }
      }
    }

    .widgetAccentable()
    .foregroundStyle(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
#if canImport(ActivityKit) && os(iOS)
    .activityBackgroundTint(springFestiveBackgroundEnabled ? Color("background").opacity(0.3) : Color.clear)
#endif
  }
}

#if DEBUG && !os(watchOS)
#Preview {
  let now = Date()
  ShichenLockScreenView(
    date: now,
    nextShichenCountdown: now.nextShichenCountdown
  )
}
#endif
