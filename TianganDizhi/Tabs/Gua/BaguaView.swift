//
//  ShierPiguaView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/8/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import Bagua
import ChineseAstrologyCalendar
import ChineseTranditionalMusicCore
import MusicTheory
import SwiftUI

// MARK: - BaguaView

struct BaguaView: View {

  // MARK: Internal

  struct ViewData {
    let guas: [Trigram]
    let title: String
  }

  @Environment(\.bodyFont) var bodyFont
  @Environment(\.titleFont) var titleFont
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.footnote) var footnote

  @State var viewData: ViewData

  @State var rotationOn = false

  var font: Font {
    #if os(watchOS)
    footnote
    #else
    largeTitleFont
    #endif
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        ForEach(viewData.guas.indices) { index in
          let gua = viewData.guas[index]

          Text(gua.chineseCharacter)
            .offset(anglePosition(for: index, in: geometry.size, z: 0))
            .font(font)

          Text(gua.symbol)
            .rotationEffect(getRotatingAngle(for: index, base: 8))
            .offset(anglePosition(for: index, in: geometry.size, z: 1))
            .font(font.bold())

          Text(gua.xiang)
            .offset(anglePosition(for: index, in: geometry.size, z: 2))
            .font(bodyFont)
        }
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
    #if os(watchOS)
    .edgesIgnoringSafeArea([.bottom,.leading,.trailing])
    #endif
    #if os(iOS) || os(watchOS)
    .navigationViewStyle(StackNavigationViewStyle())
    #endif
    .navigationTitle(viewData.title)
  }

  var outterSpacing: Double {
    #if os(watchOS)
    12
    #else
    46
    #endif
  }

  var innerSpacing: Double {
    #if os(watchOS)
    18
    #else
    60
    #endif
  }

  func getRotatingAngle(for index: Int, base: Double) -> Angle {
    let segmentAngle = 2 * .pi / base
    return .init(radians: segmentAngle * Double(index))
  }

  // MARK: Private

  private func anglePosition(for index: Int, in size: CGSize, z: Double) -> CGSize {
    let segmentAngle = 2 * .pi / Double(viewData.guas.count)

    let startAngle = segmentAngle * Double(index) - .pi * 0.5
    let adjustment = outterSpacing + z * innerSpacing
    let radius = min(size.width, size.height) / 2 -
      adjustment // Adjust the spacing between the circle and the Text elements here
    let x = cos(startAngle) * radius
    let y = sin(startAngle) * radius
    return CGSize(width: x, height: y)
  }

}

// MARK: - BaguaView_Preview

struct BaguaView_Preview: PreviewProvider {
  static var previews: some View {
    Group {
      BaguaView(viewData: .init(guas: xiantianBagua, title: "先天八卦"))
      BaguaView(viewData: .init(guas: houtianBagua, title: "後天八卦"))
    }
  }
}
