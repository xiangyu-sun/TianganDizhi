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
        VStack(spacing: 0) {
            Spacer(minLength: 6)
            
            // Top: Chinese date
            FullDateTitleView(date: date)
                .font(title3Font)
                .padding(.bottom, 4)
            
            // Moon phase icon (if enabled)
            if displayMoonPhaseOnWidgets, let moonPhase = date.chineseDay()?.moonPhase {
                HStack(spacing: 4) {
                    Image(systemName: moonPhaseIcon(for: moonPhase))
                        .font(.caption)
                    Text(moonPhase.name(traditionnal: false))
                        .font(.caption2)
                }
                .padding(.bottom, 6)
            }

            Spacer(minLength: 4)
            
            if let shichen = date.shichen {
                // Ke display with progress bar
                VStack(spacing: 2) {
                    Text("\(shichen.currentKeSpellOut)刻")
                        .font(largeTitleFont)
                    
                    // Ke progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.primary.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.primary)
                                .frame(width: geometry.size.width * keProgress, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 8)
                
                // Countdown
                Text(nextShichenCountdown)
                    .font(calloutFont)
                    .padding(.bottom, 6)
                
                // Shichen progression
                ShichenHStackView(shichen: shichen.dizhi)
                    .padding([.leading, .trailing], 8)
            }
            Spacer(minLength: 6)
        }
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
