import Bagua
import SwiftUI

// MARK: - LiushisiGuaView

struct LiushisiGuaView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.title3Font) var title3Font
  @Environment(\.footnote) var footnote
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  var font: Font {
    #if os(watchOS)
    footnote
    #else
    title3Font
    #endif
  }

  var columns: [GridItem] {
    #if os(watchOS)
    Array(repeating: GridItem(.flexible()), count: 4)
    #else
    let count = horizontalSizeClass == .compact ? 4 : 8
    return Array(repeating: GridItem(.flexible()), count: count)
    #endif
  }

  var body: some View {
    LazyVGrid(columns: columns, content: {
      ForEach(hexagramSymbols) { hexagram in
        VStack {
          Text(hexagram.symbol)
          Text(hexagram.chineseCharacter)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(hexagram.chineseCharacter)
      }
    })
    .font(font)
  }
}

#Preview {
  LiushisiGuaView()
}
