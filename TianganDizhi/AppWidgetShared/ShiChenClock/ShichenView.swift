//
//  ShichenView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/07/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

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
  let current: Bool

  var rotation: Double {
    Double((shichen.rawValue + 7) % 12)
  }

  var body: some View {
    VStack {
      Text("\(shichen.chineseCharactor)")
        .font(titleFont)
        .foregroundColor(current ? Color.primary : Color.secondary)
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