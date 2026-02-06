//
//  ShichenLiveActivity.swift
//  TianganDizhi
//
//  Created by Claude Code
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import ActivityKit
import WidgetKit
import SwiftUI
import ChineseAstrologyCalendar

// MARK: - ShichenLiveActivity

@available(iOS 16.1, *)
struct ShichenLiveActivity: Widget {
    @Environment(\.titleFont) var titleFont
    @Environment(\.calloutFont) var calloutFont
    @Environment(\.title3Font) var title3Font
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ShichenActivityAttributes.self) { context in
            // Lock Screen presentation
            ShichenLockScreenView(
                date: context.state.currentDate,
                nextShichenCountdown: context.state.nextShichenCountdown
            )
            .widgetURL(URL(string: "tiangandizhi://main"))
        } dynamicIsland: { context in
            DynamicIsland {
                expandedContent(for: context)
            } compactLeading: {
                // Compact leading - Shichen character
                if let dizhi = context.state.currentDate.shichen?.dizhi {
                    Text(dizhi.chineseCharacter)
                        .font(.system(size: 12))
                        .fontWeight(.bold)
                }
            } compactTrailing: {
                // Compact trailing - Current Ke
                if let shichen = context.state.currentDate.shichen {
                    Text("\(shichen.currentKeSpellOut)刻")
                        .font(.caption2)
                }
            } minimal: {
                // Minimal presentation - Shichen character with Ke superscript
                if let shichen = context.state.currentDate.shichen {
                    HStack(spacing: 1) {
                        Text(shichen.dizhi.chineseCharacter)
                            .font(.caption2)
                            .fontWeight(.bold)
                        Text("\(shichen.currentKe)")
                            .font(.system(size: 8))
                            .fontWeight(.medium)
                            .baselineOffset(4)
                    }
                }
            }
        }
    }
    
    @DynamicIslandExpandedContentBuilder
    func expandedContent(for context: ActivityViewContext<ShichenActivityAttributes>) -> DynamicIslandExpandedContent<some View> {
        let shichen = context.state.currentDate.shichen
        let god = context.state.currentDate.twelveGod()
        
        DynamicIslandExpandedRegion(.leading) {
            VStack(alignment: .leading, spacing: 4) {
                // Shichen character
                Text(shichen?.dizhi.chineseCharacter ?? "")
                    .font(titleFont)
                
                // Ke display
                Text("\(shichen?.currentKeSpellOut ?? "")刻")
                    .font(calloutFont)
                
                // Alias name with organ icon
                HStack(spacing: 2) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 8))
                    Text(shichen?.dizhi.aliasName ?? "")
                        .font(.caption2)
                    Text("•")
                        .font(.caption2)
                    Text(shichen?.dizhi.organReference ?? "")
                        .font(.caption2)
                }
            }
        }
        
        DynamicIslandExpandedRegion(.trailing) {
            VStack(alignment: .trailing, spacing: 4) {
                // Current time
                Text(context.state.currentDate, style: .time)
                    .font(title3Font)
                    .monospacedDigit()
                
                // Next Shichen countdown
                if !context.state.nextShichenCountdown.isEmpty {
                    let shortCountdown = context.state.nextShichenCountdown
                        .replacingOccurrences(of: "距離", with: "")
                        .replacingOccurrences(of: "還有", with: "")
                    Text(shortCountdown)
                        .font(.caption2)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        
        DynamicIslandExpandedRegion(.bottom) {
            VStack(spacing: 6) {
                // Chinese date
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(context.state.currentDate.displayStringOfChineseYearMonthDateWithZodiac)
                        .font(calloutFont)
                }
                
                // Twelve God
                if let god = god {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text(god.chinese)
                            .font(.caption)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}
