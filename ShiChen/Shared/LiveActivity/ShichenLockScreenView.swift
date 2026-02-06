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
          Text(date.displayStringOfChineseYearMonthDateWithZodiac)
            .font(title2Font)
          
          VStack() {
            Text(shichen.dizhi.displayHourText)
              .font(title2Font)
            
            Text("\(shichen.currentKeSpellOut)刻")
              .font(title2Font)
          }
        }
        
        // Countdown to next Shichen
        if !nextShichenCountdown.isEmpty {
          Text(nextShichenCountdown)
            .font(calloutFont)
            .foregroundColor(.secondary)
        }
      }
    }

    .modifier(WidgetAccentable())
    .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
#if canImport(ActivityKit) && os(iOS)
    .activityBackgroundTint(springFestiveBackgroundEnabled ? Color("background").opacity(0.3) : Color.clear)
#endif
  }
}

#if DEBUG && !os(watchOS)
struct ShichenLockScreenView_Previews: PreviewProvider {
  static var previews: some View {
    let now = Date()
    ShichenLockScreenView(
      date: now,
      nextShichenCountdown: now.nextShichenCountdown
    )
    .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
#endif
