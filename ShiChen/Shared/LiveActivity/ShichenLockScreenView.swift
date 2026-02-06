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
    let keProgress: Double

    @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
    var springFestiveForegroundEnabled = false
    @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
    var springFestiveBackgroundEnabled = false
    @AppStorage(Constants.displayMoonPhaseOnWidgets, store: Constants.sharedUserDefault)
    var displayMoonPhaseOnWidgets = false
    @Environment(\.title3Font) var title3Font
    @Environment(\.title2Font) var title2Font
    @Environment(\.largeTitleFont) var largeTitleFont
    @Environment(\.calloutFont) var calloutFont

    var body: some View {
        VStack(spacing: 4) {
            // Top: Chinese date
            FullDateTitleView(date: date)
                .font(title3Font)
            
            if let shichen = date.shichen {
                // Ke display with fixed-width progress bar
                VStack(spacing: 3) {
                    Text("\(shichen.currentKeSpellOut)刻")
                        .font(title2Font)
                    
                    // Ke progress bar with fixed width
                    HStack {
                        Spacer()
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.primary.opacity(0.2))
                                .frame(width: 120, height: 3)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.primary)
                                .frame(width: 120 * keProgress, height: 3)
                        }
                        Spacer()
                    }
                }
                
                // Countdown - smaller font
                if !nextShichenCountdown.isEmpty {
                    Text(nextShichenCountdown)
                        .font(.caption)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                // Shichen progression
                ShichenHStackView(shichen: shichen.dizhi)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .modifier(WidgetAccentable())
        .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
        #if canImport(ActivityKit) && os(iOS)
        .activityBackgroundTint(springFestiveBackgroundEnabled ? Color("background").opacity(0.3) : Color.clear)
        #endif
    }
    
    // Helper function to get moon phase SF Symbol
    private func moonPhaseIcon(for phase: ChineseMoonPhase) -> String {
        // Use a simple moon.fill icon for all phases
        // ChineseMoonPhase is a custom enum, so we'll just use a generic icon
        return "moon.fill"
    }
}

#if DEBUG && !os(watchOS)
struct ShichenLockScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ShichenLockScreenView(
            date: Date(),
            nextShichenCountdown: "距离丑时还有 45 分钟",
            keProgress: 0.6
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
