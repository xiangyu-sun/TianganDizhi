//
//  MediumWidgetView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 7/4/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import SwiftUI
import WidgetKit


// MARK: - MediumWidgetView

struct MediumWidgetView: View {
  let date: Date

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false
  
  @StateObject private var fontProvider = FontProvider()
  
  private var title3Font: Font { fontProvider.title3Font }
  private var footnote: Font { fontProvider.footnoteFont }

  #if os(iOS) || os(macOS)
  /// From the timeline entry — see `SimpleEntry.weather`.
  var weather: WeatherData.Information? = nil
  #endif

  var body: some View {
    VStack {
      Spacer(minLength: 8)
      FullDateTitleView(date: date)
          .font(title3Font)
  
      #if os(iOS) || os(macOS)
      Spacer(minLength: 4)
      if let value = weather {
        Text(
          MeasurmentFormatterManager
            .buildTemperatureDescription(high: value.temperatureHigh, low: value.temperatureLow) + "\(value.condition)")
          .font(footnote)
          .foregroundStyle(Color.secondary)
      }
      Spacer(minLength: 4)
      #else
      Spacer()
      #endif
      if let shichen = date.shichen {
        ShichenHStackView(shichen: shichen.dizhi)
          .padding([.leading, .trailing], 8)
      }
      Spacer()
    }
    .widgetAccentable()
    .foregroundStyle(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
    .materialBackgroundWidget(with: Image("background"), toogle: springFestiveBackgroundEnabled)
    .environment(\.shouldScaleFont, .widgetShouldScaleFont)
  }
}

#if !os(watchOS)
#Preview {
  MediumWidgetView(date: Date())
}
#endif
