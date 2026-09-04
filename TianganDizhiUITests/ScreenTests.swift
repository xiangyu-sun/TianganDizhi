//
//  ScreenTests.swift
//  TianganDizhiUITests
//
//  Created by Xiangyu Sun on 11/11/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import XCTest

final class ScreenTests: XCTestCase {

  var app: XCUIApplication!
  var monitor: NSObjectProtocol!

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false

    let mainScreenScreenshot = XCUIScreen.main.screenshot()
    let attachment = XCTAttachment(screenshot: mainScreenScreenshot)
    attachment.lifetime = .keepAlways
    add(attachment)

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    app = XCUIApplication()
    app.launchArguments += ["UITestMode"]
    app.launch()

    monitor = addUIInterruptionMonitor(withDescription: "") { element in
      if element.buttons["Allow Once"].exists {
        element.buttons["Allow Once"].tap()
        return true
      }
      return false
    }
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testTakeScreenshotOfPigua() {
    #if os(macOS)
    app.tabs["卦"].click()
    #else
    selectTab("卦")
    #endif
    
    // Wait for UI to stabilize after font provider initialization
    sleep(1)
    
    takingScreenShot()
  }

  func testTakeScreenshotOfMainWindow() {
    #if os(macOS)
    app.tabs["天干地支"].click()
    app.tables.cells.containing(.button, identifier: "十二地支").element.click()
    #else
    selectTab("天干地支")
    let dizhiRow = app.buttons["十二地支"]
    XCTAssertTrue(
      dizhiRow.waitForExistence(timeout: 5),
      "十二地支 row is missing from the 天干地支 tab")
    dizhiRow.tap()
    #endif

    // Wait for UI to stabilize after navigation and font provider initialization
    sleep(1)
    
    takingScreenShot()
  }

  #if !os(macOS)
  /// Taps a tab bar item and verifies it actually became selected.
  ///
  /// A bare `tap()` on a tab that is covered (by the onboarding sheet, or by a
  /// system permission alert) silently no-ops, which used to leave these tests
  /// screenshotting the wrong screen instead of failing. The first tap can also
  /// be consumed while an interruption monitor dismisses a permission alert, so
  /// retry once before giving up.
  private func selectTab(_ label: String) {
    let tab = app.tabBars.firstMatch.buttons[label]
    XCTAssertTrue(tab.waitForExistence(timeout: 10), "\(label) tab not found")

    for _ in 0 ..< 2 {
      tab.tap()
      let selected = expectation(
        for: NSPredicate(format: "isSelected == true"), evaluatedWith: tab)
      if XCTWaiter().wait(for: [selected], timeout: 5) == .completed {
        return
      }
    }
    XCTFail("\(label) tab did not become selected — something is covering the app")
  }
  #endif

  func takingScreenShot() {
    let screenshot = app.windows.firstMatch.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    attachment.lifetime = .keepAlways
    add(attachment)
  }
}
