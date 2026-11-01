import Bagua
import SwiftUI

// MARK: - LiushisiGuaView

struct LiushisiGuaView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.title3Font) var title3Font
  @Environment(\.footnote) var footnote
  @Environment(\.displayLanguage) var displayLanguage
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
          GlossedText(glyph: hexagram.localizedName(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : hexagram.localizedName(in: displayLanguage), alignment: .center)
            .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(displayLanguage.isChinese
          ? hexagram.localizedName(in: displayLanguage)
          : GlossedText.accessibilityText(glyph: hexagram.localizedName(in: displayLanguage.glyphLanguage), gloss: hexagram.localizedName(in: displayLanguage)))
      }
    })
    .font(font)
  }
}

#Preview {
  LiushisiGuaView()
}
