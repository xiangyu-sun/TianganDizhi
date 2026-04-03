import ChineseAstrologyCalendar
import SwiftUI

// MARK: - FangweiView

struct FangweiView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.title3Font) var title3Font
  @Environment(\.title2Font) var title2Font

  // Cardinal directions arranged in compass order with center last
  private let cardinalDirections: [FangWei] = [.north, .east, .south, .west]
  private let center: FangWei = .center

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Compass rose
        compassRose
          .frame(height: 340)
          .padding(.horizontal)

        // Detail list
        List {
          ForEach(FangWei.allCases, id: \.self) { direction in
            directionRow(direction)
          }
        }
        .listStyle(.plain)
        .frame(height: CGFloat(FangWei.allCases.count) * 80)
      }
      .padding(.vertical)
    }
    .navigationTitle("五方")
  }

  @ViewBuilder
  private var compassRose: some View {
    GeometryReader { geo in
      let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
      let radius: CGFloat = min(geo.size.width, geo.size.height) * 0.38

      ZStack {
        // Center node
        compassNode(fangwei: .center, size: 70)
          .position(center)

        // Cardinal nodes
        ForEach(cardinalDirections, id: \.self) { dir in
          let angle = angle(for: dir)
          let pos = CGPoint(
            x: center.x + cos(angle) * radius,
            y: center.y + sin(angle) * radius
          )
          compassNode(fangwei: dir, size: 60)
            .position(pos)
        }
      }
    }
  }

  private func compassNode(fangwei: FangWei, size: CGFloat) -> some View {
    ZStack {
      Circle()
        .fill(fangwei.wuxing.traditionalColor.opacity(0.25))
        .frame(width: size, height: size)
      Circle()
        .strokeBorder(fangwei.wuxing.traditionalColor, lineWidth: 1.5)
        .frame(width: size, height: size)
      VStack(spacing: 2) {
        Text(fangwei.chineseCharacter)
          .font(title2Font)
        Text(fangwei.wuxing.chineseCharacter)
          .font(footnote)
          .foregroundStyle(.secondary)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(fangwei.chineseCharacter)方，\(fangwei.wuxing.chineseCharacter)")
  }

  // Maps FangWei to compass angle in radians (0 = right/East in math coords)
  // North = up = -π/2, East = right = 0, South = down = π/2, West = left = π
  private func angle(for direction: FangWei) -> CGFloat {
    switch direction {
    case .north:  return -.pi / 2
    case .east:   return 0
    case .south:  return .pi / 2
    case .west:   return .pi
    case .center: return 0
    }
  }

  @ViewBuilder
  private func directionRow(_ direction: FangWei) -> some View {
    HStack(spacing: 12) {
      Circle()
        .fill(direction.wuxing.traditionalColor.opacity(0.3))
        .frame(width: 40, height: 40)
        .overlay(
          Text(direction.chineseCharacter)
            .font(title3Font)
        )

      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 8) {
          Text("五行：\(direction.wuxing.chineseCharacter)")
          Text("天干：\(direction.tiangan.0.chineseCharacter)\(direction.tiangan.1.chineseCharacter)")
        }
        .font(bodyFont)

        HStack(spacing: 4) {
          Text("地支：")
            .foregroundStyle(.secondary)
          ForEach(direction.dizhi, id: \.self) {
            Text($0.chineseCharacter)
          }
        }
        .font(footnote)
        .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 4)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(direction.chineseCharacter)方，五行\(direction.wuxing.chineseCharacter)，天干\(direction.tiangan.0.chineseCharacter)\(direction.tiangan.1.chineseCharacter)")
  }
}

#Preview {
  NavigationStack {
    FangweiView()
  }
}
