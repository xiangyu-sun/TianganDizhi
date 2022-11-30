//
//  TianganDizhiTests.swift
//  TianganDizhiTests
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import XCTest
@testable import TianganDizhi

class TianganDizhiTests: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testTimeline() {
    let timeline = ShichenTimeLineSceduler.buildTimeLine()
    XCTAssertEqual(timeline.count, 6)
    let comp: Set<Calendar.Component> = [.hour, .minute, .second, .nanosecond]

    let second = timeline[1]
    let third = timeline[2]
    let secondDP = Calendar.current.dateComponents(comp, from: second)
    let thirdDP = Calendar.current.dateComponents(comp, from: third)

    XCTAssertEqual(secondDP.minute, 0)
    XCTAssertEqual(secondDP.second, 0)
    XCTAssertEqual(secondDP.nanosecond, 0)

    XCTAssertEqual(thirdDP.minute, 0)
    XCTAssertEqual(thirdDP.second, 0)
    XCTAssertEqual(thirdDP.nanosecond, 0)

    let forth = timeline[3]
    let fivth = timeline[4]

    XCTAssertEqual(Calendar.current.dateComponents(comp, from: third, to: forth).hour, 2)
    XCTAssertEqual(Calendar.current.dateComponents(comp, from: third, to: forth).minute, 0)
    XCTAssertEqual(Calendar.current.dateComponents(comp, from: third, to: forth).second, 0)

    XCTAssertEqual(Calendar.current.dateComponents(comp, from: forth, to: fivth).hour, 2)
    XCTAssertEqual(Calendar.current.dateComponents(comp, from: forth, to: fivth).minute, 0)
    XCTAssertEqual(Calendar.current.dateComponents(comp, from: forth, to: fivth).second, 0)
  }

}
