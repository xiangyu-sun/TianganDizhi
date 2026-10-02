//
//  JIeqiListView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/8/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - JieqiListView

struct JieqiListView: View {
  private let currentJieqi = Date().jieqiDayAligned
  private let nextJieqiOccurrence = Date().nextJieqiDayAligned

  var body: some View {
    ScrollViewReader { proxy in
      List(Jieqi.allCases, id: \.self) { jieqi in
        JieqiCell(
          jieqi: jieqi,
          isCurrent: jieqi == currentJieqi,
          daysUntil: nextJieqiOccurrence?.jieqi == jieqi ? nextJieqiOccurrence.map { $0.days(from: Date(), calendar: .solarTerm) } : nil
        )
        .id(jieqi)
      }
      .onAppear {
        if let current = currentJieqi {
          proxy.scrollTo(current, anchor: .center)
        }
      }
    }
  }
}

#Preview {
  JieqiListView()
}
