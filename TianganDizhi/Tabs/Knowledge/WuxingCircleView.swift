import SwiftUI
import ChineseAstrologyCalendar
import CoreGraphics

extension Wuxing: Identifiable {
  public var id: Int {
    rawValue
  }
}

struct WuxingCircleView: View {
  let wuxings = Wuxing.allCases
  
  let radius: CGFloat = 140
  
  var body: some View {
    GeometryReader { geo in
      let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
      ZStack {
        ForEach(0..<wuxings.count, id: \ .self) { index in
          let angle = Angle(degrees: Double(index) / Double(wuxings.count) * 360.0 + 56.5)
          let pos = CGPoint(
            x: center.x + cos(angle.radians) * radius,
            y: center.y + sin(angle.radians) * radius
          )
          WuxingNodeView(wuxing: wuxings[index], color: wuxings[index].traditionalColor)
            .position(pos)
        }


        ForEach(wuxings) { wuxing in
          let partner = wuxing.sheng
          if let fromIndex = wuxings.firstIndex(of: wuxing),
             let toIndex = wuxings.firstIndex(of: partner) {
            Arrow(from: position(for: fromIndex, in: geo.size), to: position(for: toIndex, in: geo.size), color: .green, curved: false)
          }
        }
        
        ForEach(wuxings) { wuxing in
          let partner = wuxing.ke
          if let fromIndex = wuxings.firstIndex(of: wuxing),
             let toIndex = wuxings.firstIndex(of: partner) {
            Arrow(from: position(for: fromIndex, in: geo.size), to: position(for: toIndex, in: geo.size), color: .red, curved: false)
          }
        }
      }
    }
    .frame(height: 360)
  }
  
  func position(for index: Int, in size: CGSize) -> CGPoint {
    let angle = Angle(degrees: Double(index) / Double(wuxings.count) * 360.0 + 56.5)
    let center = CGPoint(x: size.width / 2, y: size.height / 2)
    return CGPoint(
      x: center.x + cos(angle.radians) * radius,
      y: center.y + sin(angle.radians) * radius
    )
  }
}

struct WuxingCircleView_Previews: PreviewProvider {
  static var previews: some View {
    WuxingCircleView()
      .padding()
  }
}
