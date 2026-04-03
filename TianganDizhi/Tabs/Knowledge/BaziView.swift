import ChineseAstrologyCalendar
import SwiftUI

// MARK: - BaziView

struct BaziView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.title3Font) var title3Font
  @Environment(\.title2Font) var title2Font

  @State private var birthDate = Date()
  @State private var showingPicker = false

  private var bazi: Bazi? {
    Bazi(date: birthDate)
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Date picker
        VStack(alignment: .leading, spacing: 8) {
          Text("出生日期時辰")
            .font(footnote)
            .foregroundStyle(.secondary)
          DatePicker("", selection: $birthDate, displayedComponents: [.date, .hourAndMinute])
            .labelsHidden()
            .font(bodyFont)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

        if let bazi {
          // Four Pillars
          pillarsSection(bazi: bazi)

          // Element balance
          elementBalanceSection(bazi: bazi)
        }
      }
      .padding()
    }
    .navigationTitle("四柱八字推算")
  }

  @ViewBuilder
  private func pillarsSection(bazi: Bazi) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("四柱")
        .font(title3Font)

      // allCharacters: [nianGan, nianZhi, yueGan, yueZhi, riGan, riZhi, shiGan, shiZhi]
      let chars = bazi.allCharacters
      HStack(spacing: 0) {
        ForEach(Array(zip(["年柱", "月柱", "日柱", "時柱"], bazi.pillars)), id: \.0) { label, ganzhi in
          let ganIndex = ["年柱": 0, "月柱": 2, "日柱": 4, "時柱": 6][label] ?? 0
          let ganChar = chars[ganIndex]
          let zhiChar = chars[ganIndex + 1]
          VStack(spacing: 6) {
            Text(label)
              .font(footnote)
              .foregroundStyle(.secondary)
            Text(ganChar)
              .font(title2Font)
              .foregroundStyle(bazi.dayMaster.chineseCharacter == ganChar ? bazi.dayMasterElement.traditionalColor : .primary)
            Text(zhiChar)
              .font(title2Font)
            Text(ganzhi.nayin.traditionalChineseName)
              .font(footnote)
              .foregroundStyle(.secondary)
              .lineLimit(1)
              .minimumScaleFactor(0.6)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background(
            ganzhi == bazi.ri
              ? AnyShapeStyle(Color.accentColor.opacity(0.12))
              : AnyShapeStyle(Color.clear)
          )
          .clipShape(RoundedRectangle(cornerRadius: 8))
        }
      }

      HStack(spacing: 4) {
        Text("日主：")
          .font(footnote)
          .foregroundStyle(.secondary)
        Text(bazi.dayMaster.chineseCharacter)
          .font(bodyFont)
          .foregroundStyle(bazi.dayMasterElement.traditionalColor)
        Text(bazi.dayMasterElement.chineseCharacter)
          .font(bodyFont)
          .foregroundStyle(bazi.dayMasterElement.traditionalColor)
      }
    }
    .padding()
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
  }

  @ViewBuilder
  private func elementBalanceSection(bazi: Bazi) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("五行分析")
        .font(title3Font)

      // Element count bars
      ForEach(Wuxing.allCases, id: \.self) { element in
        let count = bazi.elementCounts[element] ?? 0
        let isMissing = bazi.missingElements.contains(element)
        let isBeneficial = bazi.beneficialElement == element
        let isDominant = bazi.dominantElement == element

        HStack(spacing: 8) {
          Text(element.chineseCharacter)
            .font(bodyFont)
            .foregroundStyle(element.traditionalColor)
            .frame(width: 24)

          GeometryReader { geo in
            RoundedRectangle(cornerRadius: 4)
              .fill(element.traditionalColor.opacity(0.3))
              .frame(width: count > 0 ? geo.size.width * CGFloat(count) / 8.0 : 4)
          }
          .frame(height: 20)

          Text(isMissing ? "缺" : "\(count)")
            .font(footnote)
            .foregroundStyle(isMissing ? .red : .secondary)
            .frame(width: 24, alignment: .trailing)

          if isDominant {
            Text("旺")
              .font(footnote)
              .foregroundStyle(.orange)
          }
          if isBeneficial {
            Text("用神")
              .font(footnote)
              .foregroundStyle(.green)
          }
        }
      }

      HStack(spacing: 16) {
        if !bazi.missingElements.isEmpty {
          VStack(alignment: .leading, spacing: 4) {
            Text("缺失五行")
              .font(footnote)
              .foregroundStyle(.secondary)
            HStack(spacing: 4) {
              ForEach(bazi.missingElements, id: \.self) { el in
                Text(el.chineseCharacter)
                  .font(bodyFont)
                  .foregroundStyle(.red)
              }
            }
          }
        }
        Spacer()
        VStack(alignment: .trailing, spacing: 4) {
          Text("用神")
            .font(footnote)
            .foregroundStyle(.secondary)
          Text(bazi.beneficialElement.chineseCharacter)
            .font(bodyFont)
            .foregroundStyle(.green)
        }
      }
    }
    .padding()
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
  }
}

// Reuse color extension from TianganStem.swift (Wuxing.traditionalColor)

#Preview {
  NavigationStack {
    BaziView()
  }
}
