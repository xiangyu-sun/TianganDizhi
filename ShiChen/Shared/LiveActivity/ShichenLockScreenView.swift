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

    @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
    var springFestiveForegroundEnabled = false
    @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
    var springFestiveBackgroundEnabled = false
    @Environment(\.title3Font) var title3Font
    @Environment(\.title2Font) var title2Font

    var body: some View {
        VStack {
            Spacer(minLength: 8)
            FullDateTitleView(date: date)
                .font(title3Font)

            Spacer(minLength: 4)
            
            if let shichen = date.shichen {
                Text("\(shichen.currentKeSpellOut)刻")
                    .font(title2Font)
                
                ShichenHStackView(shichen: shichen.dizhi)
                    .padding([.leading, .trailing], 8)
            }
            Spacer()
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
        ShichenLockScreenView(date: Date())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
