//
//  MediumWidgetView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 7/4/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import SwiftUI

struct MediumWidgetView: View {
  @State var date: Date
  
  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false
  @Environment(\.title3Font) var title3Font
  @Environment(\.footnote) var footnote
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false
#if os(iOS) || os(macOS)
  @StateObject var weatherData = WeatherData.shared
#endif
  var body: some View {
    let shichen = date.shichen!
    
    VStack {
      Spacer(minLength: 8)
      FullDateTitleView(date: date)
        .font(title3Font)
#if os(iOS) || os(macOS)
      if let value = weatherData.forcastedWeather {
        Text(MeasurmentFormatterManager.buildTemperatureDescription(high: value.temperatureHigh, low: value.temperatureLow) + "，天氣\(value.condition)")
          .font(footnote)
          .foregroundColor(Color.secondary)
      }
#else
      Spacer()
#endif
      
      ShichenHStackView(shichen: shichen.dizhi)
        .padding([.leading, .trailing], 8)
      Spacer()
    }
    .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .materialBackground(with: Image("background"), toogle: springFestiveBackgroundEnabled)
  }
}

struct MediumWidgetView_Previews: PreviewProvider {
  static var previews: some View {
    MediumWidgetView(date: Date())
  }
}