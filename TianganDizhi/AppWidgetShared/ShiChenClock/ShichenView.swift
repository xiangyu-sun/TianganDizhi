//
//  ShichenView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/07/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import Bagua
import ChineseAstrologyCalendar
import SwiftUI

// MARK: - ShichenView

struct ShichenView: View {
  let currentShichen: Dizhi

  var body: some View {
    ZStack {
      ForEach(Dizhi.allCases, id: \.self) { dizhi in
        DizhiView(shichen: dizhi, current: currentShichen == dizhi)
      }
    }
  }
}

// MARK: - DizhiView

private struct DizhiView: View {
  let shichen: Dizhi

  @Environment(\.titleFont) var titleFont
  @Environment(\.title3Font) var title3Font
  
  let current: Bool

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false

  var rotation: Double {
    Double((shichen.rawValue + 5) % 12)
  }

  var body: some View {
    VStack {
      let color = springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary
      Text("\(shichen.chineseCharactor)")
      #if os(watchOS)
        .font(title3Font)
      #else
        .font(titleFont)
      #endif
        .foregroundColor(current ? color : Color.secondary)
        .scaleEffect(current ? 1.2 : 1)
        .rotationEffect(.radians(-(Double.pi * 2 / 12 * rotation)))

      Spacer()
    }
    .padding(25)
    .rotationEffect(.radians(Double.pi * 2 / 12 * rotation))
  }
}

// MARK: - ShichenView_Previews

struct ShichenView_Previews: PreviewProvider {
  static var previews: some View {
    ShichenView(currentShichen: .zi)
      .scaledToFit()
  }
}
