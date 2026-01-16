//
//  TianganDizhiTests.swift
//  TianganDizhiTests
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import Testing
import Foundation
@testable import TianganDizhi

struct ShichenTimeLineSchedulerTests {

  @Test("Timeline contains exactly 12 entries")
  func timelineCount() {
    let timeline = ShichenTimeLineSceduler.buildTimeLine()
    #expect(timeline.count == 12)
  }

  @Test("Timeline entries have normalized time components at hour boundaries")
  func timelineEntriesNormalized() {
    let timeline = ShichenTimeLineSceduler.buildTimeLine()
    let comp: Set<Calendar.Component> = [.hour, .minute, .second, .nanosecond]

    let second = timeline[1]
    let third = timeline[2]
    let secondDP = Calendar.current.dateComponents(comp, from: second)
    let thirdDP = Calendar.current.dateComponents(comp, from: third)

    #expect(secondDP.minute == 0)
    #expect(secondDP.second == 0)
    #expect(secondDP.nanosecond == 0)

    #expect(thirdDP.minute == 0)
    #expect(thirdDP.second == 0)
    #expect(thirdDP.nanosecond == 0)
  }

  @Test("Timeline entries are spaced exactly 1 hour apart")
  func timelineHourlySpacing() {
    let timeline = ShichenTimeLineSceduler.buildTimeLine()
    let comp: Set<Calendar.Component> = [.hour, .minute, .second, .nanosecond]

    let third = timeline[2]
    let forth = timeline[3]
    let fivth = timeline[4]

    let thirdToForth = Calendar.current.dateComponents(comp, from: third, to: forth)
    #expect(thirdToForth.hour == 1)
    #expect(thirdToForth.minute == 0)
    #expect(thirdToForth.second == 0)

    let forthToFivth = Calendar.current.dateComponents(comp, from: forth, to: fivth)
    #expect(forthToFivth.hour == 1)
    #expect(forthToFivth.minute == 0)
    #expect(forthToFivth.second == 0)
  }
}
