//
//  ShichenWatch_Watch_AppUITestsLaunchTests.swift
//  ShichenWatch Watch AppUITests
//
//  Created by Xiangyu Sun on 23/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import XCTest

final class ShichenWatch_Watch_AppUITestsLaunchTests: XCTestCase {

  override class var runsForEachTargetApplicationUIConfiguration: Bool {
    true
  }

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testLaunch() throws {
    let app = XCUIApplication()
    app.launch()

    // Insert steps here to perform after app launch but before taking a screenshot,
    // such as logging into a test account or navigating somewhere in the app

    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = "Launch Screen"
    attachment.lifetime = .keepAlways
    add(attachment)
  }
}
