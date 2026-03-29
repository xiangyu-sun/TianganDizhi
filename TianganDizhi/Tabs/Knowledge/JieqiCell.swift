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

  var body: some View {
    #if os(watchOS)

    VStack(alignment: .leading) {
      HStack {
        Text(jieqi.chineseName)
        Text("(\(jieqi.qi ? "氣" : "節"))")
      }
      .font(title3Font)
      Text(jieqi.qishierHou)
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
        HStack {
          Text(jieqi.chineseName)
          Text("(\(jieqi.qi ? "氣" : "節"))")
        }
        .font(title3Font)
        Text(jieqi.qishierHou)
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
    #endif
  }
}

#Preview {
  JieqiCell(jieqi: .bailu)
}
