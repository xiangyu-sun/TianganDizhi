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

  /// Optional binding for the currently selected Wuxing element.
  /// When nil, all sheng/ke arrows are shown at full opacity.
  @Binding var selectedWuxing: Wuxing?

  let radius: CGFloat = 140
  /// Half the diameter of WuxingNodeView's circle (100pt), plus a small gap.
  let nodeRadius: CGFloat = 54

  var body: some View {
    GeometryReader { geo in
      let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
      ZStack {
        // Draw sheng (相生) arrows first so nodes render on top
        ForEach(wuxings) { wuxing in
          let partner = wuxing.sheng
          if let fromIndex = wuxings.firstIndex(of: wuxing),
             let toIndex = wuxings.firstIndex(of: partner) {
            let isHighlighted = selectedWuxing == nil
              || selectedWuxing == wuxing
              || selectedWuxing == partner
            let (trimFrom, trimTo) = trimmed(
              from: position(for: fromIndex, in: geo.size),
              to: position(for: toIndex, in: geo.size)
            )
            Arrow(from: trimFrom, to: trimTo, color: .green, curved: false)
              .opacity(isHighlighted ? 1.0 : 0.15)
          }
        }

        // Draw ke (相克) arrows
        ForEach(wuxings) { wuxing in
          let partner = wuxing.ke
          if let fromIndex = wuxings.firstIndex(of: wuxing),
             let toIndex = wuxings.firstIndex(of: partner) {
            let isHighlighted = selectedWuxing == nil
              || selectedWuxing == wuxing
              || selectedWuxing == partner
            let (trimFrom, trimTo) = trimmed(
              from: position(for: fromIndex, in: geo.size),
              to: position(for: toIndex, in: geo.size)
            )
            Arrow(from: trimFrom, to: trimTo, color: .red, curved: false)
              .opacity(isHighlighted ? 1.0 : 0.15)
          }
        }

        // Draw nodes on top of arrows
        ForEach(0..<wuxings.count, id: \.self) { index in
          let wuxing = wuxings[index]
          let angle = Angle(degrees: Double(index) / Double(wuxings.count) * 360.0 + 56.5)
          let pos = CGPoint(
            x: center.x + cos(angle.radians) * radius,
            y: center.y + sin(angle.radians) * radius
          )
          let isSelected = selectedWuxing == wuxing
          let isDimmed = selectedWuxing != nil && !isRelated(wuxing)

          WuxingNodeView(wuxing: wuxing, color: wuxing.traditionalColor, isSelected: isSelected)
            .position(pos)
            .opacity(isDimmed ? 0.35 : 1.0)
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .animation(.spring(response: 0.3), value: selectedWuxing)
            .onTapGesture {
              if selectedWuxing == wuxing {
                selectedWuxing = nil
              } else {
                selectedWuxing = wuxing
              }
            }
        }
      }
    }
    .frame(height: 360)
  }

  /// Returns true if the given wuxing is related to the currently selected one
  /// (either as sheng partner or ke partner, in either direction).
  private func isRelated(_ wuxing: Wuxing) -> Bool {
    guard let selected = selectedWuxing else { return true }
    if wuxing == selected { return true }
    // 我生 / 生我
    if selected.sheng == wuxing || wuxing.sheng == selected { return true }
    // 我克 / 克我
    if selected.ke == wuxing || wuxing.ke == selected { return true }
    return false
  }

  /// Shortens a line segment so it starts/ends at the node circle edge rather than the center.
  private func trimmed(from: CGPoint, to: CGPoint) -> (CGPoint, CGPoint) {
    let dx = to.x - from.x
    let dy = to.y - from.y
    let len = sqrt(dx * dx + dy * dy)
    guard len > nodeRadius * 2 else { return (from, to) }
    let ux = dx / len
    let uy = dy / len
    let newFrom = CGPoint(x: from.x + ux * nodeRadius, y: from.y + uy * nodeRadius)
    let newTo   = CGPoint(x: to.x   - ux * nodeRadius, y: to.y   - uy * nodeRadius)
    return (newFrom, newTo)
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

#Preview {
  struct PreviewContainer: View {
    @State var selected: Wuxing? = nil
    var body: some View {
      WuxingCircleView(selectedWuxing: $selected)
        .padding()
    }
  }
  return PreviewContainer()
}
