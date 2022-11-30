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
        .foregroundColor(.secondary)
      ShichenView(currentShichen: currentShichen)
        .padding(padding)
    }
  }
}

// MARK: - CircularContainerView_Previews

struct CircularContainerView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      CircularContainerView(currentShichen: .chen, padding: 0)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}
