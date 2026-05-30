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

  let jieqi: Jieqi
  var isCurrent: Bool = false
  var daysUntil: Int? = nil

  var body: some View {
    #if os(watchOS)
    VStack(alignment: .leading) {
      jieqiHeader
      Text(jieqi.qishierHou)
        .font(bodyFont)
      Text(jieqi.healthTip)
        .font(bodyFont)
      Text(jieqi.seasonalFoods)
        .font(bodyFont)

      Image(uiImage: jieqi.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .accessibilityHidden(true)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(jieqi.chineseName)，\(jieqi.qi ? "氣" : "節")，\(jieqi.qishierHou)")

    #else
    HStack {
      VStack(alignment: .leading) {
        jieqiHeader
        Text(jieqi.qishierHou)
          .font(bodyFont)
        Text(jieqi.healthTip)
          .font(bodyFont)
        Text(jieqi.seasonalFoods)
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
    .accessibilityLabel("\(jieqi.chineseName)，\(jieqi.qi ? "氣" : "節")，\(jieqi.qishierHou)")
    .listRowBackground(isCurrent ? Color.accentColor.opacity(0.12) : Color.clear)
    #endif
  }

  private var jieqiHeader: some View {
    HStack {
      HStack {
        Text(jieqi.chineseName)
        Text("(\(jieqi.qi ? "氣" : "節"))")
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
