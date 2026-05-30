import ChineseAstrologyCalendar
import SwiftUI

// MARK: - BaziView

struct BaziView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.title3Font) var title3Font

  @State private var birthDate = Date()
  @State private var isMale = true
  @State private var useChinaTimezone = false

  private var adjustedBirthDate: Date {
    guard useChinaTimezone else { return birthDate }
    let chinaOffset = 8 * 3600
    let localOffset = TimeZone.current.secondsFromGMT(for: birthDate)
    return birthDate.addingTimeInterval(TimeInterval(chinaOffset - localOffset))
  }

  private var bazi: Bazi? { Bazi(date: adjustedBirthDate) }

  private var daYun: (startAge: Int, cycles: [DaYun])? {
    DaYunCalculator.calculate(birthDate: adjustedBirthDate, isMale: isMale)
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Date + options picker
        VStack(alignment: .leading, spacing: 8) {
          Text("出生日期時辰")
            .font(footnote)
            .foregroundStyle(.secondary)
          DatePicker("", selection: $birthDate, displayedComponents: [.date, .hourAndMinute])
            .labelsHidden()
            .font(bodyFont)

          Picker("性別", selection: $isMale) {
            Text("男").tag(true)
            Text("女").tag(false)
          }
          #if !os(watchOS)
          .pickerStyle(.segmented)
          #endif

          VStack(alignment: .leading, spacing: 4) {
            Toggle("出生地在中國大陸／港澳台", isOn: $useChinaTimezone)
              .font(bodyFont)
            if useChinaTimezone && TimeZone.current.secondsFromGMT() != 8 * 3600 {
              Text("換算後：\(adjustedBirthDate.formatted(date: .abbreviated, time: .shortened))")
                .font(footnote)
                .foregroundStyle(.secondary)
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 12))

        if let bazi {
          BaziPillarsSection(bazi: bazi)
          BaziElementBalanceSection(bazi: bazi)
        }

        if let daYun {
          BaziDaYunSection(startAge: daYun.startAge, cycles: daYun.cycles)
        }
      }
      .padding()
    }
    .navigationTitle("四柱八字推算")
  }
}

// MARK: - BaziPillarsSection

struct BaziPillarsSection: View {
  let bazi: Bazi
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.title3Font) var title3Font
  @Environment(\.title2Font) var title2Font

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("四柱")
        .font(title3Font)

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
          .clipShape(.rect(cornerRadius: 8))
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
    .background(.regularMaterial, in: .rect(cornerRadius: 12))
  }
}

// MARK: - BaziElementBalanceSection

struct BaziElementBalanceSection: View {
  let bazi: Bazi
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.title3Font) var title3Font

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("五行分析")
        .font(title3Font)

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
    .background(.regularMaterial, in: .rect(cornerRadius: 12))
  }
}

// MARK: - BaziDaYunSection

struct BaziDaYunSection: View {
  let startAge: Int
  let cycles: [DaYun]
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.title3Font) var title3Font

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("大運")
          .font(title3Font)
        Spacer()
        Text("起運：\(startAge)歲")
          .font(footnote)
          .foregroundStyle(.secondary)
      }

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(cycles) { cycle in
            VStack(spacing: 4) {
              Text(cycle.tiangan.chineseCharacter)
                .font(bodyFont)
                .foregroundStyle(cycle.tiangan.wuxing.traditionalColor)
              Text(cycle.dizhi.chineseCharacter)
                .font(bodyFont)
                .foregroundStyle(cycle.dizhi.wuxing.traditionalColor)
              Text("\(cycle.startAge)")
                .font(footnote)
                .foregroundStyle(.secondary)
            }
            .frame(width: 44)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: .rect(cornerRadius: 8))
          }
        }
        .padding(.horizontal, 2)
      }
    }
    .padding()
    .background(.regularMaterial, in: .rect(cornerRadius: 12))
  }
}

#Preview {
  NavigationStack {
    BaziView()
  }
}
