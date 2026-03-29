//
//  DateProvider.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 28/10/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import Combine
import SwiftUI

final class DateProvider: ObservableObject {

  // MARK: Lifecycle

  init() {
    // Fire every second, but only publish when the displayed Shichen or Ke actually changes.
    // Shichen changes every ~2 hours; Ke changes every ~15 minutes.
    // This prevents triggering full view rebuilds every second unnecessarily.
    Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .map { _ in Date() }
      .filter { [weak self] newDate in
        guard let self else { return true }
        let current = self.currentDate
        // Re-publish only when the minute changes (Ke updates are minute-level)
        let cal = Calendar.current
        return cal.component(.minute, from: newDate) != cal.component(.minute, from: current)
      }
      .prepend(Date())
      .assign(to: &$currentDate)
  }

  // MARK: Internal

  @Published var currentDate = Date()
}
