//
//  WuxingRelationshipView.swift
//  TianganDizhi
//

import ChineseAstrologyCalendar
import ChineseTranditionalMusicCore
import JingluoShuxue
import MusicTheory
import SwiftUI

// MARK: - WuxingRelationshipView

/// Comprehensive Five Elements (五行) page that combines:
/// - Interactive circular diagram with tap-to-select for sheng/ke highlighting
/// - Dynamic relationship detail panel showing 我生/生我/我克/克我
/// - Full attribute list at the bottom
struct WuxingRelationshipView: View {

  @State private var selectedWuxing: Wuxing? = nil

  @Environment(\.bodyFont) var bodyFont
  @Environment(\.title3Font) var title3Font
  @Environment(\.footnote) var footnote

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {

        // MARK: Interactive circle diagram
        WuxingCircleView(selectedWuxing: $selectedWuxing)
          .padding(.horizontal)

        // MARK: Hint text
        if selectedWuxing == nil {
          Text("點擊五行節點查看相生相克關係")
            .font(footnote)
            .foregroundStyle(.secondary)
        } else {
          Button("清除選擇") { selectedWuxing = nil }
            .font(footnote)
        }

        // MARK: Relationship detail panel
        RelationshipDetailPanel(selectedWuxing: selectedWuxing)
          .padding(.horizontal)

        Divider()
          .padding(.horizontal)

        // MARK: Full attribute list
        Text("五行屬性")
          .font(title3Font)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal)

        WuxingAttributeList(selectedWuxing: selectedWuxing)
          .padding(.horizontal)
      }
      .padding(.vertical)
    }
    .navigationTitle("五行相生相克")
  }
}

// MARK: - RelationshipDetailPanel

/// Shows the four sheng/ke relationships for the selected Wuxing,
/// or a full overview table when nothing is selected.
private struct RelationshipDetailPanel: View {

  let selectedWuxing: Wuxing?

  @Environment(\.bodyFont) var bodyFont
  @Environment(\.title3Font) var title3Font
  @Environment(\.footnote) var footnote
  @Environment(\.displayLanguage) var displayLanguage

  var body: some View {
    if let wuxing = selectedWuxing {
      selectedView(wuxing: wuxing)
    } else {
      overviewView()
    }
  }

  // Detail panel for a selected element
  @ViewBuilder
  private func selectedView(wuxing: Wuxing) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("\(wuxing.sentenceText(in: displayLanguage)) 的生克關係")
        .font(title3Font)
        .foregroundStyle(wuxing.traditionalColor)

      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
        relationshipCard(
          label: "我生",
          description: "\(wuxing.sentenceText(in: displayLanguage))生\(wuxing.sheng.sentenceText(in: displayLanguage))",
          arrowColor: .green
        )
        relationshipCard(
          label: "生我",
          description: "\(beShengBy(wuxing).sentenceText(in: displayLanguage))生\(wuxing.sentenceText(in: displayLanguage))",
          arrowColor: .green
        )
        relationshipCard(
          label: "我克",
          description: "\(wuxing.sentenceText(in: displayLanguage))克\(wuxing.ke.sentenceText(in: displayLanguage))",
          arrowColor: .red
        )
        relationshipCard(
          label: "克我",
          description: "\(beKeBy(wuxing).sentenceText(in: displayLanguage))克\(wuxing.sentenceText(in: displayLanguage))",
          arrowColor: .red
        )
      }
    }
    .padding()
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
  }

  // Overview table when nothing is selected
  @ViewBuilder
  private func overviewView() -> some View {
    VStack(alignment: .leading, spacing: 0) {
      overviewHeader()
      Divider()
      ForEach(Wuxing.allCases) { wuxing in
        overviewRow(wuxing: wuxing)
        if wuxing != Wuxing.allCases.last {
          Divider()
        }
      }
    }
    .padding()
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
  }

  private func overviewHeader() -> some View {
    HStack {
      Text("五行").font(footnote).foregroundStyle(.secondary).frame(width: labelWidth, alignment: .leading)
      Spacer()
      Text("相生").font(footnote).foregroundStyle(.green).frame(minWidth: columnWidth)
      Text("相克").font(footnote).foregroundStyle(.red).frame(minWidth: columnWidth)
    }
    .padding(.vertical, 4)
  }

  private func overviewRow(wuxing: Wuxing) -> some View {
    HStack {
      GlossedText(glyph: wuxing.chineseCharacter, gloss: wuxing.gloss(in: displayLanguage))
        .font(bodyFont)
        .foregroundStyle(wuxing.traditionalColor)
        .frame(width: labelWidth, alignment: .leading)
      Spacer()
      // 我生
      HStack(spacing: 2) {
        Text("生").font(footnote).foregroundStyle(.green)
        GlossedText(glyph: wuxing.sheng.chineseCharacter, gloss: wuxing.sheng.gloss(in: displayLanguage))
          .font(bodyFont)
          .foregroundStyle(wuxing.sheng.traditionalColor)
      }
      .frame(minWidth: columnWidth)
      // 我克
      HStack(spacing: 2) {
        Text("克").font(footnote).foregroundStyle(.red)
        GlossedText(glyph: wuxing.ke.chineseCharacter, gloss: wuxing.ke.gloss(in: displayLanguage))
          .font(bodyFont)
          .foregroundStyle(wuxing.ke.traditionalColor)
      }
      .frame(minWidth: columnWidth)
    }
    .padding(.vertical, 6)
  }

  // English glosses need more room than the single glyphs.
  private var labelWidth: CGFloat { displayLanguage.isChinese ? 36 : 56 }
  private var columnWidth: CGFloat { displayLanguage.isChinese ? 60 : 96 }

  // MARK: Relationship card

  private func relationshipCard(
    label: LocalizedStringKey,
    description: LocalizedStringKey,
    arrowColor: Color
  ) -> some View {
    VStack(spacing: 6) {
      Text(label)
        .font(footnote)
        .foregroundStyle(.secondary)
      Text(description)
        .font(bodyFont)
        .foregroundStyle(arrowColor)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 10)
    .background(arrowColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .stroke(arrowColor.opacity(0.3), lineWidth: 1)
    )
  }

  // MARK: Helper – reverse lookup

  /// Returns the Wuxing that sheng (生) the given one.
  private func beShengBy(_ wuxing: Wuxing) -> Wuxing {
    Wuxing.allCases.first { $0.sheng == wuxing } ?? wuxing
  }

  /// Returns the Wuxing that ke (克) the given one.
  private func beKeBy(_ wuxing: Wuxing) -> Wuxing {
    Wuxing.allCases.first { $0.ke == wuxing } ?? wuxing
  }
}

// MARK: - WuxingAttributeList

/// Renders per-element attribute rows, filtering to the selected element when set.
private struct WuxingAttributeList: View {

  let selectedWuxing: Wuxing?

  @Environment(\.bodyFont) var bodyFont
  @Environment(\.title2Font) var title2Font
  @Environment(\.title3Font) var title3Font
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.footnote) var footnote
  @Environment(\.displayLanguage) var displayLanguage
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  private var displayedElements: [Wuxing] {
    if let selected = selectedWuxing {
      return [selected]
    }
    return Wuxing.allCases
  }

  var body: some View {
    LazyVGrid(columns: [GridItem(.flexible(), spacing: 0)], alignment: .leading, spacing: 8) {
      ForEach(displayedElements, id: \.self) { item in
        wuxingRow(item: item)
      }
    }
  }

  func wuxingRow(item: Wuxing) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .firstTextBaseline) {
          Text("\(item.chineseCharacter)")
            .font(horizontalSizeClass != .compact ? largeTitleFont : title2Font)
          if !displayLanguage.isChinese {
            Text(item.localizedName(in: displayLanguage))
              .font(title3Font)
              .foregroundStyle(.secondary)
          }
        }

        HStack {
          VStack(alignment: .leading, spacing: 0) {
            Text("天干")
              .font(footnote)
            HStack {
              Text("\(item.tiangan.0.chineseCharacter)")
              Text("\(item.tiangan.1.chineseCharacter)")
            }
            .font(horizontalSizeClass != .compact ? title3Font : bodyFont)
            Divider()
            Text("地支")
              .font(footnote)
            HStack {
              ForEach(item.dizhi) {
                Text("\($0.chineseCharacter)")
                  .font(horizontalSizeClass != .compact ? title3Font : bodyFont)
              }
            }
          }
          .scaledToFit()

          Divider()

          VStack(alignment: .leading, spacing: 0) {
            Text("臟腑和情緒")
              .font(footnote)
            HStack {
              let wuzang = 五臟.allCases.first { $0.wuxing == item } ?? .心
              GlossedText(glyph: wuzang.localizedName(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : wuzang.localizedName(in: displayLanguage))

              let wufu = 五腑.allCases.first { $0.wuxing == item } ?? .小腸
              GlossedText(glyph: wufu.localizedName(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : wufu.localizedName(in: displayLanguage))
              // 情緒 is library prose, which exists only in Chinese.
              Text("\(wuzang.情緒.converted(to: displayLanguage))")
            }
            .font(horizontalSizeClass != .compact ? title3Font : bodyFont)

            Divider()

            Text("五味")
              .font(footnote)
            HStack {
              GlossedText(glyph: item.localizedFlavor(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : item.localizedFlavor(in: displayLanguage))
                .font(horizontalSizeClass != .compact ? title3Font : bodyFont)
            }
          }
          .scaledToFit()

          Divider()
          makeTopicView(title: "五音", detail: "\(Key.wuyin.first { $0.wuxing == item }?.localizedWuyinName(in: displayLanguage) ?? "")")

          Divider()

          makeTopicView(title: "方位", detail: "\(item.fangwei.localizedName(in: displayLanguage.glyphLanguage))", gloss: displayLanguage.isChinese ? "" : item.fangwei.localizedName(in: displayLanguage))
          makeTopicView(title: "色彩", detail: "\(item.localizedColorDescription(in: displayLanguage.glyphLanguage))", gloss: displayLanguage.isChinese ? "" : item.localizedColorDescription(in: displayLanguage))

          Divider()

          if let season = Season.allCases.first(where: { $0.wuxing == item }) {
            makeTopicView(title: "四季", detail: season.localizedName(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : season.localizedName(in: displayLanguage))
          }
        }
      }
    }
    .accessibilityElement(children: .combine)
  }

  fileprivate func makeTopicView(title: LocalizedStringKey, detail: String, gloss: String = "") -> some View {
    VStack {
      Text(title)
        .font(footnote)
      HStack {
        GlossedText(glyph: detail, gloss: gloss, alignment: .center)
          .font(horizontalSizeClass != .compact ? title3Font : bodyFont)
      }
    }
  }
}

// MARK: - Previews

#Preview {
  NavigationStack {
    WuxingRelationshipView()
  }
}
