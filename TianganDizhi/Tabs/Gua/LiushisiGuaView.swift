import Bagua
import SwiftUI

// MARK: - LiushisiGuaView

struct LiushisiGuaView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.title3Font) var title3Font
  @Environment(\.footnote) var footnote

  var font: Font {
    #if os(watchOS)
    footnote
    #else
    title3Font
    #endif
  }

  var body: some View {
    LazyVGrid(columns: [
      GridItem(.flexible(minimum: 80)),
      GridItem(.flexible(minimum: 80)),
      GridItem(.flexible(minimum: 80)),
      GridItem(.flexible(minimum: 80)),
      GridItem(.flexible(minimum: 80)),
      GridItem(.flexible(minimum: 80)),
      GridItem(.flexible(minimum: 80)),
      GridItem(.flexible(minimum: 80)),
    ], content: {
      ForEach(hexagramSymbols) { hexagram in
        VStack {
          Text(hexagram.symbol)
          Text(hexagram.chineseCharacter)
        }
      }
    })
    .font(font)
  }
}

// MARK: - YijingView_Previews

struct YijingView_Previews: PreviewProvider {
  static var previews: some View {
    LiushisiGuaView()
  }
}
