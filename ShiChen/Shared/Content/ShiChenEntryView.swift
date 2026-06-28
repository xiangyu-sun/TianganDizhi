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
import JingluoShuxue

// MARK: - ShiChenEntryView

struct ShiChenEntryView: View {
  var entry: ShichenTimelineProvider.Entry
  @Environment(\.widgetFamily) var family
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  
  // Create local font provider for widgets that reads from shared UserDefaults
  @StateObject private var fontProvider = FontProvider()

  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false

  @AppStorage(Constants.displayMoonPhaseOnWidgets, store: Constants.sharedUserDefault)
  var displayMoonPhaseOnWidgets = true
  
  // Computed font properties for convenience
  private var largeTitleFont: Font { fontProvider.largeTitleFont }
  private var bodyFont: Font { fontProvider.bodyFont }
  private var footnote: Font { fontProvider.footnoteFont }
  private var titleFont: Font { fontProvider.titleFont }
  private var title3Font: Font { fontProvider.title3Font }

  var body: some View {
    switch family {
    case .accessoryInline:
        if horizontalSizeClass != .compact {
          HStack(spacing: 0) {
            Text(entry.date.displayStringOfChineseYearMonthDateWithZodiac)
            if let shichen = entry.date.shichen {
              //let keString = "\(NumberFormatter.tranditionalChineseNunmberFormatter.string(from: NSNumber(value: shichen.currentKe)) ?? "")刻"
              Text(shichen.dizhi.displayHourText)
            }
          }
          .font(.body)
          .widgetAccentable()
        } else {
          InlineWidgetView(date: entry.date)
        }
      

    case .accessoryCircular:
        CircularWidgetView(date: entry.date)
      

    case .accessoryRectangular:
        RetangularWidgetView(date: entry.date)
      
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
//              Text(
//                "\(NumberFormatter.tranditionalChineseNunmberFormatter.string(from: NSNumber(value: shichen.currentKe)) ?? "")刻"
//              )
//              .font(titleFont)      
            
              Text(shichen.dizhi.aliasName)
                .font(titleFont)
              Text(shichen.dizhi.luizhu.organReference)
                .font(bodyFont)
            }
          }
        }
        .padding(.bottom, 8)
      }
      .widgetAccentable()
      .foregroundStyle(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
      .materialBackgroundWidget(with: Image("background"), toogle: springFestiveBackgroundEnabled)

    case .systemExtraLarge:
      if horizontalSizeClass != .compact {
        #if os(iOS)
        ExtraLargeWidgetView(date: entry.date)
          .widgetAccentable()
        #endif
      } else {
        ZStack {
          VStack(spacing: 0) {
            FullDateTitleView(date: entry.date)
              .font(title3Font)
            
            Text(entry.date.jieQiDisplayText)
              .font(bodyFont)

            if let shichen = entry.date.shichen {
              CircularContainerView(currentShichen: shichen.dizhi, padding: -30)
            }
          }
          .foregroundStyle(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)

          if let shichen = entry.date.shichen {
            VStack {
              Text(shichen.dizhi.aliasName)
                .font(largeTitleFont)
              Text(shichen.dizhi.luizhu.organReference)
                .font(bodyFont)
            }
            .padding(.top, 8)
          }
        }
        .widgetAccentable()
        .materialBackgroundWidget(with: Image("background"), toogle: springFestiveBackgroundEnabled)
      }

    default:
      if let shichen = entry.date.shichen {
        CompactShichenView(shichen: shichen.dizhi, date: entry.date)
          .widgetAccentable()
          .foregroundStyle(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .materialBackgroundWidget(with: Image("background"), toogle: springFestiveBackgroundEnabled)
      } else {
        EmptyView()
      }
    }
  }
}

#if os(iOS)
#Preview("Inline") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("Circular") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("Retangular") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("systemSmall") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("systemMedium") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("systemLarge") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("systemLarge Dark") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .environment(\.colorScheme, .dark)
}

#Preview("systemExtraLarge") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("systemMedium XXL") {
  ShiChenEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
    .environment(\.sizeCategory, .extraExtraLarge)
}
#endif
