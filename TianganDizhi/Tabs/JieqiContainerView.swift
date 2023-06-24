//
//  ShierPiguaView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/8/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar
import ChineseTranditionalMusicCore
import MusicTheory

struct ShierPiguaView: View {
  
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  
  @Environment(\.iPad) var iPad
  
  var body: some View {
    NavigationView() {
      GeometryReader { geometry in
        ZStack {
          ForEach(Jieqi.allCases, id: \.self) { jieqi in
            Text(jieqi.chineseName)
              .font(bodyFont)
              .offset(anglePosition(for: jieqi.rawValue - 1, in: geometry.size))
            
            let dizhi = Dizhi(rawValue: jieqi.rawValue / 2) ?? .chen
            let dizhiIndex = dizhi.rawValue - 1
            
            Text(Key.shierLvLvMonthOrder[dizhiIndex].lvlvDescription)
              .font(bodyFont)
              .offset(angle12Position(for: dizhiIndex, in: geometry.size, z: 1))
            
            
            Text(iPad ? dizhi.chineseCalendarMonthName : dizhi.chineseCharactor)
              .font(bodyFont)
              .offset(angle12Position(for: (dizhiIndex - 2), in: geometry.size, z: 2))
          }
          
          
          ForEach(0..<12) { index in
            Path { path in
              let segmentAngle = 2 * .pi / Double(12)
              
              let circleRadius = min(geometry.size.width, geometry.size.height) / 2
              let center = CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5) // Adjust center coordinates to match the circle's center
              let angle = 2 * .pi * Double(index) / Double(12) - segmentAngle * 0.5
              let radius: CGFloat = circleRadius
              
              let endPoint = CGPoint(
                x: center.x + radius * CGFloat(cos(angle)),
                y: center.y + radius * CGFloat(sin(angle))
              )
              
              path.move(to: center)
              path.addLine(to: endPoint)
            }
            .stroke(Color.secondary, lineWidth: 2)
          }
          
          Circle()
            .stroke(lineWidth: 4)
            .foregroundColor(.secondary)
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
      }
      .navigationTitle("十二辟卦")
    }
  }
  
  private func anglePosition(for index: Int, in size: CGSize) -> CGSize {
    let segmentAngle = 2 * .pi / Double(Jieqi.allCases.count)
    
    let startAngle = segmentAngle * Double(index) + .pi - segmentAngle * 0.5
    
    let radius = min(size.width, size.height) / 2 - 30 // Adjust the spacing between the circle and the Text elements here
    let x = cos(startAngle) * radius
    let y = sin(startAngle) * radius
    return CGSize(width: x, height: y)
  }
  
  private func angle12Position(for index: Int, in size: CGSize, z: Double) -> CGSize {
    let segmentAngle = 2 * .pi / Double(12)
    
    let startAngle = segmentAngle * Double(index) + .pi
    let adjustment = z * 90
    let radius = (min(size.width, size.height) -  adjustment) / 2 - 30  // Adjust the spacing between the circle and the Text elements here
    let x = cos(startAngle) * radius
    let y = sin(startAngle) * radius
    return CGSize(width: x, height: y)
  }
}

struct ShierPiguaView_Previews: PreviewProvider {
  static var previews: some View {
    ShierPiguaView()
  }
}
