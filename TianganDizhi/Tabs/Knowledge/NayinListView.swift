import ChineseAstrologyCalendar
import SwiftUI

// MARK: - NayinListView

struct NayinListView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote

  // Each Nayin is shared by two consecutive Ganzhi (e.g. 甲子/乙丑 → 海中金)
  let jiazi = getJiazhi()

  var body: some View {
    List {
      // Walk the 60 ganzhi in pairs; each pair shares one Nayin
      ForEach(stride(from: 0, to: jiazi.count, by: 2).map { $0 }, id: \.self) { index in
        let first = jiazi[index]
        let second = jiazi[index + 1]
        let nayin = first.nayin

        HStack {
          VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
              Text(first.description)
              Text(second.description)
            }
            .font(bodyFont)
            Text(nayin.wuxing.chineseCharacter)
              .font(footnote)
              .foregroundStyle(.secondary)
          }
          Spacer()
          Text(nayin.traditionalChineseName)
            .font(bodyFont)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(first.description)、\(second.description)，\(nayin.traditionalChineseName)")
      }
    }
    .navigationTitle("六十納音")
  }
}

#Preview {
  NavigationStack {
    NayinListView()
  }
}
