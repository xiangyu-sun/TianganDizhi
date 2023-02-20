//
//  MoonAndSunInformationView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 20/2/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import SwiftUI

struct SunInformationView: View {
  @State var info: WeatherData.Information
  @Environment(\.bodyFont) var bodyFont
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false
  
  var body: some View {
    HStack() {
      if let sunrise = info.sunrise {
        HStack(spacing: 0) {
          Text(sunrise, style: .time)
          Text("日出")
        }
        .font(bodyFont)
      }
      if let sunset = info.sunset {
        HStack(spacing: 0) {
          Text(sunset, style: .time)
          Text("日落")
        }
        .font(bodyFont)
      }
    }
  }
}

@available(iOS 15, *)
struct MoonAndSunInformationView_Previews: PreviewProvider {
    static var previews: some View {
      SunInformationView(info: WeatherData.Information(moonPhase: .上弦月,
                                                   moonRise: .now,
                                                   moonset: .now,
                                                   sunrise: .now,
                                                   sunset: .now,
                                                   noon: .now,
                                                   midnight: .now,
                                                   temperatureHigh: .init(value: 12, unit: .celsius), temperatureLow: .init(value: 30, unit: .celsius),
                                                              condition: "ok"
                                                             )
      )
    }
}
