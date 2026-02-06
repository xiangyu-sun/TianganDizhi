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
            ShichenLockScreenView(date: context.state.currentDate)
        } dynamicIsland: { context in
            DynamicIsland {
                expandedContent(for: context)
            } compactLeading: {
                // Compact leading - Shichen character
                let dizhi = context.state.currentDate.shichen?.dizhi
                Text(dizhi?.chineseCharacter ?? "")
                    .font(.caption2)
                    .fontWeight(.bold)
            } compactTrailing: {
                // Compact trailing - Current Shichen name
                Text(context.state.currentDate.shichen?.dizhi.displayHourText ?? "")
                    .font(.caption2)
            } minimal: {
                // Minimal presentation - Just the Shichen character
                let dizhi = context.state.currentDate.shichen?.dizhi
                Text(dizhi?.chineseCharacter ?? "")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
        }
    }
    
    @DynamicIslandExpandedContentBuilder
    func expandedContent(for context: ActivityViewContext<ShichenActivityAttributes>) -> DynamicIslandExpandedContent<some View> {
        let shichen = context.state.currentDate.shichen
        let god = context.state.currentDate.twelveGod()
        
        DynamicIslandExpandedRegion(.leading) {
            VStack {
                Text(shichen?.dizhi.chineseCharacter ?? "")
                    .font(titleFont)
                Text("\(shichen?.currentKeSpellOut ?? "")刻")
                    .font(calloutFont)
                Text(shichen?.dizhi.aliasName ?? "")
                    .font(.caption2)
            }
        }
        
        DynamicIslandExpandedRegion(.trailing) {
            VStack {
                Text(context.state.currentDate, style: .time)
                    .font(title3Font)
                    .monospacedDigit()
                Text(shichen?.dizhi.organReference ?? "")
                    .font(.caption2)
            }
        }
        
        DynamicIslandExpandedRegion(.bottom) {
            HStack {
                Text(context.state.currentDate.displayStringOfChineseYearMonthDateWithZodiac)
                    .font(calloutFont)
                Text(god?.chinese ?? "")
                    .font(calloutFont)
            }
            .padding(.top, 8)
        }
    }
}
