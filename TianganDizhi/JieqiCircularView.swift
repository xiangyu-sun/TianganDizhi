//
//  JieqiCircularView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/8/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI

import ChineseAstrologyCalendar

// MARK: - JieqiCircularView

struct JieqiCircularView: View {
  @State var currentJieqi: Jieqi?

  var body: some View {
    ZStack {
      ForEach(Jieqi.allCases, id: \.self) { jieqi in
        JieqiView(jieqi: jieqi, selectedJieqi: $currentJieqi) { _ in
          currentJieqi = jieqi
        }
      }
    }
  }
}

// MARK: - JieqiView

private struct JieqiView: View {
  let jieqi: Jieqi
  @Environment(\.bodyFont) var bodyFont
  @Binding var selectedJieqi: Jieqi?

  var onTap: (Jieqi) -> Void?

  var rotation: Double {
    Double(jieqi.rawValue + 90)
  }

  var body: some View {
    VStack {
      Text("\(jieqi.chineseName)")
        .font(bodyFont)
        .foregroundColor(selectedJieqi == jieqi ? Color.primary : Color.secondary)
        .scaleEffect(selectedJieqi == jieqi ? 1.2 : 1)
        .rotationEffect(.degrees(-rotation))
      Spacer()
    }
    .rotationEffect(.degrees(rotation))
    .onTapGesture {
      onTap(jieqi)
    }
  }
}

// MARK: - JieqiCircularView_Previews

struct JieqiCircularView_Previews: PreviewProvider {
  static var previews: some View {
    JieqiCircularView(currentJieqi: .guyu)
      .scaledToFit()
  }
}
