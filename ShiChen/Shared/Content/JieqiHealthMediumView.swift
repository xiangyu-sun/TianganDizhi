//
//  JieqiHealthMediumView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 3/4/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - JieqiHealthMediumView

@available(iOSApplicationExtension 17.0, *)
struct JieqiHealthMediumView: View {
  let date: Date

  @StateObject private var fontProvider = FontProvider()

  private var title3Font: Font { fontProvider.title3Font }
  private var footnoteFont: Font { fontProvider.footnoteFont }
  private var calloutFont: Font { fontProvider.calloutFont }

  var body: some View {
    let upcomingResult = date.nextJieqi
    let jieqi = upcomingResult?.jieqi ?? date.jieqi

    if let jieqi {
      VStack(alignment: .leading, spacing: 4) {
        Text(date.jieQiDisplayText)
          .frame(alignment: .leading)
          .lineLimit(1)
          .font(title3Font)
        
        // Health tip
        Text(jieqi.healthTip)
          .font(footnoteFont)
          .lineLimit(2)
        
        // Seasonal foods
        Text(jieqi.seasonalFoods)
          .font(footnoteFont)
          .lineLimit(2)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 8)
      .modifier(WidgetAccentable())
      .containerBackground(for: .widget) {
#if os(macOS)
        Image(nsImage: jieqi.image)
          .resizable()
          .scaledToFill()
#else
        Image(uiImage: jieqi.image)
          .resizable()
          .scaledToFill()
#endif
      }
    } else {
      VStack() {
        Text(date.jieQiDisplayText)
          .font(title3Font)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      #if !os(watchOS)
      .materialBackgroundWidget()
      #endif
    }
  }
}

#if os(iOS)
@available(iOSApplicationExtension 17.0, *)
#Preview(as: .systemMedium, widget: {
  JieqiHealthWidget()
}, timeline: {
  JieqiHealthEntry(date: Date(), configuration: .init())
})
#endif
