//
//  JieqiCell.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/8/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - JieqiCell

struct JieqiCell: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.title3Font) var title3Font
  @Environment(\.displayLanguage) var displayLanguage

  let jieqi: Jieqi
  var isCurrent: Bool = false
  var daysUntil: Int? = nil

  var body: some View {
    #if os(watchOS)
    VStack(alignment: .leading) {
      jieqiHeader
      Text(jieqi.qishierHou.converted(to: displayLanguage))
        .font(bodyFont)
      Text(jieqi.healthTip.converted(to: displayLanguage))
        .font(bodyFont)
      Text(jieqi.seasonalFoods.converted(to: displayLanguage))
        .font(bodyFont)

      Image(uiImage: jieqi.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .accessibilityHidden(true)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityText)

    #else
    HStack {
      VStack(alignment: .leading) {
        jieqiHeader
        Text(jieqi.qishierHou.converted(to: displayLanguage))
          .font(bodyFont)
        Text(jieqi.healthTip.converted(to: displayLanguage))
          .font(bodyFont)
        Text(jieqi.seasonalFoods.converted(to: displayLanguage))
          .font(bodyFont)
      }
      #if os(macOS)
      Image(nsImage: jieqi.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .accessibilityHidden(true)
      #else
      Image(uiImage: jieqi.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .accessibilityHidden(true)
      #endif
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityText)
    .listRowBackground(isCurrent ? Color.accentColor.opacity(0.12) : Color.clear)
    #endif
  }

  /// Name, 節/氣 and 七十二候; outside Chinese the name is followed by its English
  /// gloss and the (Chinese-only) 節/氣 marker is dropped.
  private var accessibilityText: String {
    if displayLanguage.isChinese {
      return "\(jieqi.localizedName(in: displayLanguage))，\((jieqi.qi ? "氣" : "節").converted(to: displayLanguage))，\(jieqi.qishierHou.converted(to: displayLanguage))"
    }
    return GlossedText.accessibilityText(glyph: jieqi.localizedName(in: displayLanguage.glyphLanguage), gloss: jieqi.localizedName(in: displayLanguage)) + ", " + jieqi.qishierHou
  }

  private var jieqiHeader: some View {
    HStack {
      HStack {
        GlossedText(glyph: jieqi.localizedName(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : jieqi.localizedName(in: displayLanguage))
        if displayLanguage.isChinese {
          Text("(\((jieqi.qi ? "氣" : "節").converted(to: displayLanguage)))")
        }
      }
      .font(title3Font)

      if isCurrent {
        Text("當前")
          .font(.caption.bold())
          .foregroundStyle(.white)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Color.accentColor, in: .capsule)
      } else if let days = daysUntil {
        Text("\(days)日後")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }
}

#Preview {
  JieqiCell(jieqi: .whiteDew, isCurrent: true)
}
