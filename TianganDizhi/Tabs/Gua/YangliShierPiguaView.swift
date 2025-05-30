//
//  ShierPiguaView 2.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 21/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//

import Bagua
import ChineseAstrologyCalendar
import ChineseTranditionalMusicCore
import MusicTheory
import SwiftUI

// MARK: - YangliShierPiguaView

struct YangliShierPiguaView: View {

  // MARK: Internal

  @Environment(\.bodyFont) var bodyFont
  @Environment(\.titleFont) var titleFont
  @Environment(\.footnote) var footnote

  @Environment(\.shouldScaleFont) var shouldScaleFont

  @AppStorage(Constants.piGuaRotationEnabled, store: Constants.sharedUserDefault)
  var piGuaRotationEnabled = false

  @State var rotationOn = false

  var font: Font {
    #if os(watchOS)
    footnote
    #else
    shouldScaleFont ? titleFont : bodyFont
    #endif
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        ForEach(Jieqi.allCases, id: \.self) { jieqi in
          Text(jieqi.chineseName)
            .rotationEffect(getRotatingAngle(for: jieqi.rawValue, base: 24))
            .offset(anglePosition(for: jieqi.rawValue, in: geometry.size))

          if jieqi.rawValue.isMultiple(of: 2) {
            let dizhi = Dizhi(rawValue: (jieqi.rawValue / 2) + 1) ?? .chen
            let dizhiIndex = dizhi.rawValue - 1

            let monthIndex = jieqi.monthFromCelestialLongitude
            let monthName = localizedMonthName(from: monthIndex) ?? ""

            Text(monthName)
              .rotationEffect(getRotatingAngle(for: dizhiIndex, base: 12))
              .offset(angle12Position(for: dizhiIndex, in: geometry.size, z: 1))

            let gua = ShierPiguas[dizhiIndex]
            HStack {
              if shouldScaleFont {
                Text(gua.symbol)
              }
              Text(gua.chineseCharacter)
            }
            .rotationEffect(getRotatingAngle(for: dizhiIndex - 1, base: 12))
            .offset(angle12Position(for: dizhiIndex - 1, in: geometry.size, z: 2))
          }
        }
        .font(font)

        ForEach(0..<12) { index in
          Path { path in
            let segmentAngle = 2 * .pi / Double(12)

            let circleRadius = min(geometry.size.width, geometry.size.height) / 2
            let center = CGPoint(
              x: geometry.size.width * 0.5,
              y: geometry.size.height * 0.5) // Adjust center coordinates to match the circle's center
            let angle = 2 * .pi * Double(index) / Double(12) - segmentAngle * 0.5
            let radius: CGFloat = circleRadius

            let endPoint = CGPoint(
              x: center.x + radius * CGFloat(cos(angle)),
              y: center.y + radius * CGFloat(sin(angle)))

            path.move(to: center)
            path.addLine(to: endPoint)
          }
          .stroke(Color.secondary, lineWidth: strokeLineWidth)
        }

        Circle()
          .stroke(lineWidth: circleLineWidth)
          .foregroundColor(.secondary)
      }

      .frame(width: geometry.size.width, height: geometry.size.height)
    }
    #if os(watchOS)
    .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
    #endif
    #if os(iOS) || os(watchOS)
    .navigationViewStyle(StackNavigationViewStyle())
    #endif
    .navigationTitle("陽曆十二辟卦")
  }

  var strokeLineWidth: Double {
    #if os(watchOS)
    1
    #else
    2
    #endif
  }

  var circleLineWidth: Double {
    #if os(watchOS)
    1
    #else
    4
    #endif
  }

  var outterSpacing: Double {
    #if os(watchOS)
    12
    #else
    shouldScaleFont ? 46 : 30
    #endif
  }

  var innerSpacing: Double {
    #if os(watchOS)
    18
    #else
    shouldScaleFont ? 80 : 40
    #endif
  }

  func localizedMonthName(from number: Int, locale: Locale = Locale.current) -> String? {
    guard (1...12).contains(number) else { return nil }

    var dateComponents = DateComponents()
    dateComponents.month = number
    let calendar = Calendar(identifier: .gregorian)

    if let date = calendar.date(from: dateComponents) {
      let formatter = DateFormatter()
      formatter.locale = locale
      formatter.dateFormat = "LLLL" // Full month name
      return formatter.string(from: date)
    }

    return nil
  }

  func getRotatingAngle(for index: Int, base: Double) -> Angle {
    if piGuaRotationEnabled {
      let segmentAngle = 2 * .pi / base
      if base == 12 {
        return .init(radians: segmentAngle * Double(index) + .pi * 0.5)

      } else {
        return .init(radians: segmentAngle * Double(index) + .pi * 0.5 - 0.5 * segmentAngle)
      }
    } else {
      return .zero
    }
  }

  // MARK: Private

  private func anglePosition(for index: Int, in size: CGSize) -> CGSize {
    let segmentAngle = 2 * .pi / Double(Jieqi.allCases.count)

    let startAngle = segmentAngle * Double(index) + .pi - segmentAngle * 0.5

    let radius = min(size.width, size.height) / 2 -
      outterSpacing // Adjust the spacing between the circle and the Text elements here
    let x = cos(startAngle) * radius
    let y = sin(startAngle) * radius
    return CGSize(width: x, height: y)
  }

  private func angle12Position(for index: Int, in size: CGSize, z: Double) -> CGSize {
    let segmentAngle = 2 * .pi / Double(12)

    let startAngle = segmentAngle * Double(index) + .pi
    let adjustment = outterSpacing + z * innerSpacing
    let radius = min(size.width, size.height) / 2 - adjustment // Adjust the spacing between the circle and the Text elements here
    let x = cos(startAngle) * radius
    let y = sin(startAngle) * radius
    return CGSize(width: x, height: y)
  }
}

// MARK: - YangliShierPiguaView_Previews

struct YangliShierPiguaView_Previews: PreviewProvider {
  static var previews: some View {
    YangliShierPiguaView()
  }
}
