//
//  TianganCycleView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 15/7/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//


import SwiftUI
import ChineseAstrologyCalendar
import CoreGraphics


struct TianganHeView: View {
  let stems = Tiangan.allCases
  let radius: CGFloat = 140
  
  var body: some View {
    GeometryReader { geo in
      let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
      
      ZStack {
        ForEach(0..<stems.count, id: \ .self) { index in
          let angle = Angle(degrees: Double(index) / Double(stems.count) * 360.0)
          let pos = CGPoint(
            x: center.x + cos(angle.radians) * radius,
            y: center.y + sin(angle.radians) * radius
          )
          
          
          TianganNodeView(stem: stems[index], color: stems[index].heWuxing.traditionalColor)
            .position(pos)
        }
        
        // 合 Cycle
        ForEach(stems) { stem in
          let partner = stem.hePartner
          if let fromIndex = stems.firstIndex(of: stem),
             let toIndex = stems.firstIndex(of: partner) {
            Arrow(from: position(for: fromIndex, in: geo.size), to: position(for: toIndex, in: geo.size), color: .green)
          }
        }
      }
    }
    .frame(height: 360)
  }
  
  func position(for index: Int, in size: CGSize) -> CGPoint {
    let angle = Angle(degrees: Double(index) / Double(stems.count) * 360.0)
    let center = CGPoint(x: size.width / 2, y: size.height / 2)
    return CGPoint(
      x: center.x + cos(angle.radians) * radius,
      y: center.y + sin(angle.radians) * radius
    )
  }
}

struct TianganHeView_Previews: PreviewProvider {
  static var previews: some View {
    TianganHeView()
      .padding()
  }
}
