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
    let displayDate = date.jieqiWidgetDisplayDate()

    if let jieqi = displayDate.jieqi {
      HStack(alignment: .top, spacing: 10) {

        // Right: Text content
        VStack(alignment: .leading, spacing: 4) {
          // Jieqi name + type indicator
          HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(jieqi.chineseName)
              .font(title3Font)
            Text("(\(jieqi.qi ? "氣" : "節"))")
              .font(calloutFont)
              .foregroundStyle(.secondary)
          }

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
      }
      .padding(.horizontal, 8)
      .modifier(WidgetAccentable())
      .containerBackground(for: .widget) {
        Image(uiImage: jieqi.image)
          .resizable()
          .scaledToFill()
      }
    } else {
      Text(date.jieQiDisplayText)
        .font(title3Font)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
          Image("background")
            .resizable(resizingMode: .tile)
        }
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
