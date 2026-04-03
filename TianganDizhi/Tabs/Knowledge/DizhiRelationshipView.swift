import ChineseAstrologyCalendar
import SwiftUI

// MARK: - DizhiRelationshipView

struct DizhiRelationshipView: View {
  let dizhi: Dizhi
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.title3Font) var title3Font
  @Environment(\.footnote) var footnote

  var body: some View {
    List {
      Section(header: Text("六冲")) {
        HStack {
          Text(dizhi.chineseCharacter)
          Text("冲")
          Text(dizhi.chong.chineseCharacter)
          Spacer()
          Text(dizhi.chong.chineseCharacter + "冲" + dizhi.chineseCharacter)
            .foregroundStyle(.secondary)
        }
        .font(bodyFont)
      }

      Section(header: Text("六合")) {
        ForEach(Dizhi.allCases, id: \.self) { other in
          if let liuhe = dizhi.liuHe(with: other) {
            HStack {
              Text(liuhe.branches.0.chineseCharacter + liuhe.branches.1.chineseCharacter)
              Text("合")
              Text(liuhe.resultingElement.chineseCharacter)
              Spacer()
              Text(liuhe.chineseName)
                .foregroundStyle(.secondary)
            }
            .font(bodyFont)
          }
        }
      }

      Section(header: Text("三合")) {
        ForEach(dizhi.sanHeTriads, id: \.chineseName) { sanhe in
          HStack {
            Text(sanhe.branches.0.chineseCharacter)
            Text(sanhe.branches.1.chineseCharacter)
            Text(sanhe.branches.2.chineseCharacter)
            Text("合")
            Text(sanhe.resultingElement.chineseCharacter)
            Spacer()
            Text(sanhe.chineseName)
              .foregroundStyle(.secondary)
          }
          .font(bodyFont)
        }
        if dizhi.sanHeTriads.isEmpty {
          Text("無三合")
            .font(bodyFont)
            .foregroundStyle(.secondary)
        }
      }

      Section(header: Text("六害")) {
        ForEach(Dizhi.allCases, id: \.self) { other in
          if let liuhai = dizhi.liuHai(with: other) {
            HStack {
              Text(liuhai.branches.0.chineseCharacter)
              Text("害")
              Text(liuhai.branches.1.chineseCharacter)
              Spacer()
              Text(liuhai.chineseName)
                .foregroundStyle(.secondary)
            }
            .font(bodyFont)
          }
        }
      }
    }
    .navigationTitle(dizhi.chineseCharacter + "的關係")
  }
}

#Preview {
  NavigationStack {
    DizhiRelationshipView(dizhi: .zi)
  }
}
