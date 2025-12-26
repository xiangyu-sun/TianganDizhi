//
//  ShiChenYearMonthDateEntryView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 12/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - ShiChenYearMonthDateEntryView

struct ShiChenYearMonthDateEntryView: View {
  var entry: SimpleEntry
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.titleFont) var titleFont
  @Environment(\.title2Font) var title2Font
  @Environment(\.title3Font) var title3Font
  @Environment(\.widgetFamily) var family
  
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  
  var body: some View {
    let shichen = entry.date.shichen

    switch family {
    case .accessoryInline:
      if #available(iOSApplicationExtension 16.1, *) {
        InlineWidgetView(date: entry.date)
      }

    case .accessoryCircular:
      if #available(iOSApplicationExtension 16.1, *) {
        CircularWidgetView(date: entry.date)
          .containerBackgroundForWidget {
            Color.clear
          }
      }

    case .accessoryRectangular:
      RetangularWidgetView(date: entry.date)
        .containerBackgroundForWidget(content: { Color.clear })

    case .systemSmall:
      VStack {
        Spacer()
        Text(entry.date.displayStringOfChineseYearMonthDateWithZodiac)
          .font(footnote)
        Text(
          "\(shichen?.dizhi.displayHourText ?? "")"
        )
          .font(titleFont)
        
//        Text(
//          "\(NumberFormatter.tranditionalChineseNunmberFormatter.string(from: NSNumber(value: shichen?.currentKe ?? 0)) ?? "")刻"
//        )
//        .font(bodyFont)
        
      }
      .modifier(WidgetAccentable())
      .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .materialBackgroundWidget(with: Image("background"), toogle: springFestiveBackgroundEnabled)

    case .systemMedium:
      WidgetMediumView(entry: entry)

    default:
      VStack {
        Spacer()
        Text(entry.date.displayStringOfChineseYearMonthDateWithZodiac)
          .font(bodyFont)
          .padding([.leading, .trailing], 15)
        Text(shichen?.dizhi.displayHourText ?? "")
          .font(titleFont)
        Spacer()
      }
      .modifier(WidgetAccentable())
      .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .materialBackgroundWidget(with: Image("background"), toogle: springFestiveBackgroundEnabled)
    }
  }
}

// MARK: - WidgetMediumView

private struct WidgetMediumView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.titleFont) var titleFont
  @Environment(\.title2Font) var title2Font
  @Environment(\.title3Font) var title3Font

  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false

  var entry: SimpleEntry

  var shichen: Shichen? {
    entry.date.shichen
  }

  var body: some View {
    VStack {
      Spacer()
      HStack() {
        Text(entry.date.displayStringOfChineseYearMonthDateWithZodiac)
        Text(entry.date.twelveGod()?.chinese ?? "")
      }
      .font(title2Font)
      .padding([.leading, .trailing], 15)
      .modifier(WidgetAccentable())
      
      HStack() {
        Text(shichen?.dizhi.displayHourText ?? "")
//        Text(
//          "\(NumberFormatter.tranditionalChineseNunmberFormatter.string(from: NSNumber(value: shichen?.currentKe ?? 0)) ?? "")刻"
//        )
      }
      .font(titleFont)
      .modifier(WidgetAccentable())
      
      Spacer()
    }
    .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .materialBackgroundWidget(with: Image("background"), toogle: springFestiveBackgroundEnabled)
  }
}

// MARK: - ShiChenYearMonthDateEntryView_Previews

struct ShiChenYearMonthDateEntryView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
      #if os(watchOS)
        .previewContext(WidgetPreviewContext(family: .accessoryInline))
      #else
        .previewContext(WidgetPreviewContext(family: .systemSmall))
      #endif
        .previewDisplayName("systemSmall")

      ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
      #if os(watchOS)
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
      #else
        .previewContext(WidgetPreviewContext(family: .systemMedium))
      #endif
        .previewDisplayName("systemMedium")
    }
    #if os(iOS)
    if #available(iOSApplicationExtension 16.0, *) {
      Group {
        ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryInline))
          .previewDisplayName("ShiChenYearMonthDateEntryView accessoryInline")

        ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryCircular))
          .previewDisplayName("ShiChenYearMonthDateEntryView accessoryCircular")

        ShiChenYearMonthDateEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
          .previewDisplayName("ShiChenYearMonthDateEntryView accessoryRectangular")
      }
    }
    #endif
  }
}
