//
//  JieqiContainerView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/8/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct JieqiContainerView: View {
  @State private var rotation: Double = 0.0
  @GestureState private var dragOffset: CGSize = .zero
  
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  
  let numberOfItems = 24
  let rotationSensitivity: Double = 2.0 // Adjust the rotation sensitivity here
  
  var body: some View {
    NavigationView() {
      GeometryReader { geometry in
        ZStack {
          ForEach(Jieqi.allCases, id: \.self) { jieqi in
            Text(jieqi.chineseName)
              .font(bodyFont)
              .cornerRadius(4)
              .offset(anglePosition(for: jieqi.rawValue - 1, in: geometry.size))
          }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .overlay(
          Color.clear
            .contentShape(Rectangle())
            .gesture(
              DragGesture()
                .updating($dragOffset) { value, state, _ in
                  state = value.translation
                }
                .onChanged { value in
                  let dragDistance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                  let diagonalLength = sqrt(pow(geometry.size.width, 2) + pow(geometry.size.height, 2))
                  
                  
                  let uppertHalf = value.startLocation.y <= (geometry.size.height * 0.5)
                  
                  
                  let touchOffsetX = Double((uppertHalf ? -value.translation.width : value.translation.width) / diagonalLength)
                  
                  let rightHalf = value.startLocation.x >= (geometry.size.width * 0.5)
                  
                  let touchOffsetY = Double((rightHalf ? -value.translation.height : value.translation.height) / diagonalLength)
                  
                  rotation -= (touchOffsetX + touchOffsetY) * 2 * .pi * rotationSensitivity / Double(dragDistance)
                }
            )
        )
      }
      .navigationTitle("二十四節氣")
    }
  }
  
  private func anglePosition(for index: Int, in size: CGSize) -> CGSize {
    let segmentAngle = 2 * .pi / Double(numberOfItems)
    let rotationOffset = rotation.truncatingRemainder(dividingBy: 2 * .pi)
    let startAngle = -segmentAngle * Double(index) + rotationOffset
    let radius = min(size.width, size.height) / 2 - 30 // Adjust the spacing between the circle and the Text elements here
    let x = cos(startAngle) * radius
    let y = sin(startAngle) * radius
    return CGSize(width: x, height: y)
  }
}

struct JieqiContainerView_Previews: PreviewProvider {
  static var previews: some View {
    JieqiContainerView()
  }
}
