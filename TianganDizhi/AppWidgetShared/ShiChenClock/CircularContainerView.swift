//
//  ClockView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/07/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - CircularContainerView

struct CircularContainerView: View {
  let currentShichen: Dizhi
  let padding: CGFloat

  var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 4)
        .foregroundStyle(.secondary)
        .accessibilityHidden(true)
      ShichenView(currentShichen: currentShichen)
        .padding(padding)
    }
    // Treat the whole clock as a single accessible element describing the current shichen
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text("當前時辰：\(currentShichen.chineseCharacter)，\(currentShichen.displayHourText)"))
    .accessibilityAddTraits(.updatesFrequently)
  }
}

#Preview {
  CircularContainerView(currentShichen: .chen, padding: 0)
    .fixedSize(horizontal: false, vertical: true)
}
