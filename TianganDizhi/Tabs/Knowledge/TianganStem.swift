import SwiftUI
import ChineseAstrologyCalendar
import CoreGraphics

// MARK: - Traditional Color for Heavenly Stems (五行色彩)
extension Wuxing {
  /// Traditional color linked to the stem's Five-Element association.
  /// Colors are chosen for sufficient contrast in both light and dark mode:
  ///   - Metal (白): uses a warm silver-gray instead of pure white (avoids 1:1 contrast on light bg)
  ///   - Water (黑): uses a dark navy instead of pure black (avoids 1:1 contrast on dark bg)
  ///   - Earth (黃): uses a deeper amber-gold instead of bright yellow (improves contrast on white)
  public var traditionalColor: Color {
    switch self {
    case .metal:   // Metal (金) -> 白/銀 (silver-white)
      return Color(red: 0.75, green: 0.75, blue: 0.80)
    case .wood:     // Wood (木) -> 青 (cyan-green)
      return Color(red: 0.0, green: 153.0/255.0, blue: 102.0/255.0)
    case .water:    // Water (水) -> 黑/深藍 (dark navy)
      return Color(red: 0.10, green: 0.12, blue: 0.35)
    case .fire:  // Fire (火) -> 赤 (scarlet red)
      return Color(red: 230.0/255.0, green: 0.0, blue: 38.0/255.0)
    case .earth:      // Earth (土) -> 黃/琥珀 (deep amber-gold)
      return Color(red: 0.80, green: 0.55, blue: 0.0)
    }
  }
}

extension Tiangan: Identifiable {
  public var id: Int {
    rawValue
  }
  
  /// Traditional color linked to the stem's Five-Element association.
  public var traditionalColor: Color {
    self.wuxing.traditionalColor
  }
}


struct TianganCycleView: View {
  let stems = Tiangan.allCases
  let wuxings = [.wood, .fire, Wuxing.metal, .water]
  
  let radius: CGFloat = 140
  
  var body: some View {
    GeometryReader { geo in
      let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
      
      ZStack {
        ForEach(0..<wuxings.count, id: \ .self) { index in
          
          let angle = Angle(degrees: Double(index) / 4 * 360.0)
          let pos = CGPoint(
            x: center.x + cos(angle.radians) * radius,
            y: center.y + sin(angle.radians) * radius
          )
          WuxingNodeView(wuxing: wuxings[index], color: wuxings[index].traditionalColor)
            .position(pos)
        }
        
        WuxingNodeView(wuxing: .earth, color: Wuxing.earth.traditionalColor)
          .position(center)
        
//        // 冲 Cycle
//        ForEach(stems) { stem in
//          if let partner = stem.chongPartner,
//             let fromIndex = stems.firstIndex(of: stem),
//             let toIndex = stems.firstIndex(of: partner) {
//            Arrow(from: position(for: fromIndex, in: geo.size), to: position(for: toIndex, in: geo.size), color: .red, curved: true)
//          }
//        }
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

struct TianganNodeView: View {
  let stem: Tiangan
  let color: Color
  
  var body: some View {
    VStack {
      Circle()
        .fill(color.opacity(stem.yin ? 0.5 : 0.7))
        .frame(width: 50, height: 50)
        .overlay(Text(stem.chineseCharacter).font(.title2).bold().foregroundStyle(.primary))
      Text(stem.yin ? "陰" : "陽").font(.caption)
    }
  }
}

struct WuxingNodeView: View {
  let wuxing: Wuxing
  let color: Color
  
  var body: some View {
    ZStack {
      Circle()
        .stroke(color.opacity(0.7))
        .frame(width: 100, height: 100)
      Text(wuxing.chineseCharacter).font(.title2).bold().foregroundStyle(.primary)
      
      HStack() {
        TianganNodeView(stem: wuxing.tiangan.0, color: wuxing.tiangan.0.traditionalColor)
      }
      .offset(.init(width: -40, height: 0))
      HStack() {
        TianganNodeView(stem: wuxing.tiangan.1, color: wuxing.tiangan.1.traditionalColor)
      }
      .offset(.init(width: 40, height: 0))
    }
  }
}

struct Arrow: View {
  let from: CGPoint
  let to: CGPoint
  let color: Color
  var curved: Bool = false
  
  var body: some View {
    Path { path in
      path.move(to: from)
      if curved {
        let mid = CGPoint(x: (from.x + to.x)/2, y: (from.y + to.y)/2 - 30)
        path.addQuadCurve(to: to, control: mid)
      } else {
        path.addLine(to: to)
      }
    }
    .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
    .overlay(
      Triangle()
        .fill(color)
        .frame(width: 10, height: 10)
        .position(to)
    )
  }
}

struct Triangle: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.midX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}

#Preview {
  TianganCycleView()
    .padding()
}
