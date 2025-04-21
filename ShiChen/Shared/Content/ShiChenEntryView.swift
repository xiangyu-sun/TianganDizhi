//
//  ShiChenEntryView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 12/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - ShiChenEntryView

struct ShiChenEntryView: View {
  var entry: ShichenTimelineProvider.Entry
  @Environment(\.widgetFamily) var family
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.titleFont) var titleFont
  @Environment(\.title3Font) var title3Font
  @Environment(\.iPad) var iPad
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false

  @AppStorage(Constants.displayMoonPhaseOnWidgets, store: Constants.sharedUserDefault)
  var displayMoonPhaseOnWidgets = true

  var body: some View {
    switch family {
    case .accessoryInline:
      if #available(iOSApplicationExtension 16.1, *) {
        if iPad {
          HStack {
            Text(entry.date.displayStringOfChineseYearMonthDateWithZodiac)
            if let shichen = entry.date.shichen {
              Text(shichen.dizhi.displayHourText)
            }
          }
          .font(.custom(.weibeiBold, size: 20, relativeTo: .body))
          .widgetAccentable()
        } else {
          InlineWidgetView(date: entry.date)
        }
      }

    case .accessoryCircular:
      if #available(iOSApplicationExtension 16.0, *) {
        CircularWidgetView(date: entry.date)
      }

    case .accessoryRectangular:
      if #available(iOSApplicationExtension 16.0, *) {
        RetangularWidgetView(date: entry.date)
      }
    #if os(watchOS)
    case .accessoryCorner:
      CornerView(date: entry.date)
        .widgetAccentable()
    #endif

    case .systemMedium:
      MediumWidgetView(date: entry.date)

    case .systemLarge:

      VStack(spacing: 0) {
        FullDateTitleView(date: entry.date)
          .font(title3Font)
          .padding(.vertical, 8)
        ZStack(alignment: .center) {
          if let shichen = entry.date.shichen {
            CircularContainerView(currentShichen: shichen.dizhi, padding: -20)
            VStack {
              Text(shichen.dizhi.aliasName)
                .font(largeTitleFont)
              Text(shichen.dizhi.organReference)
                .font(bodyFont)
            }
          }
        }
        .padding(.bottom, 8)
      }
      .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .materialBackgroundWidget(with: Image("background"), toogle: springFestiveBackgroundEnabled)

    case .systemExtraLarge:
      if iPad {
        #if os(iOS)
        ExtraLargeWidgetView(date: entry.date)
        #endif
      } else {
        ZStack {
          VStack(spacing: 0) {
            FullDateTitleView(date: entry.date)
              .font(title3Font)

            Text(entry.date.jieQiText)
              .font(bodyFont)

            if let shichen = entry.date.shichen {
              CircularContainerView(currentShichen: shichen.dizhi, padding: -30)
            }
          }
          .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)

          if let shichen = entry.date.shichen {
            VStack {
              Text(shichen.dizhi.aliasName)
                .font(largeTitleFont)
              Text(shichen.dizhi.organReference)
                .font(bodyFont)
            }
            .padding(.top, 8)
          }
        }
        .materialBackgroundWidget(with: Image("background"), toogle: springFestiveBackgroundEnabled)
      }

    default:
      if let shichen = entry.date.shichen {
        CompactShichenView(shichen: shichen.dizhi, date: entry.date)
          .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .materialBackgroundWidget(with: Image("background"), toogle: springFestiveBackgroundEnabled)
      } else {
        EmptyView()
      }
    }
  }
}

// MARK: - ShiChenEntryView_Previews

struct ShiChenEntryView_Previews: PreviewProvider {
  static var previews: some View {
    #if os(iOS)
    if #available(iOSApplicationExtension 16.0, *) {
      Group {
        ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryInline))
          .previewDisplayName("Inline")

        ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryCircular))
          .previewDisplayName("Circular")

        ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
          .previewDisplayName("Retangular")
      }
    }
    Group {
      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemLarge))

      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemLarge))
        .environment(\.colorScheme, .dark)
        .previewDisplayName("systemLarge Dark")

      if #available(iOSApplicationExtension 15.0, *) {
        ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
          .previewDisplayName("systemExtraLarge")
      }

      ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .environment(\.sizeCategory, .extraExtraLarge)
        .previewDisplayName("systemMedium")
    }
    #endif
  }
}
