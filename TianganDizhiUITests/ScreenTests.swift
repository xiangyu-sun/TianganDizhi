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
    app.tabBars.firstMatch.buttons["卦"].tap()
    #endif
    takingScreenShot()
  }

  func testTakeScreenshotOfMainWindow() {
    #if os(macOS)
    app.tabs["天干地支"].click()
    app.tables.cells.containing(.button, identifier: "十二地支").element.click()
    #else
    app.tabBars.firstMatch.buttons["天干地支"].tap()
    app.buttons["十二地支"].tap()
    #endif

    takingScreenShot()
  }

  func testTakeScreenshotOfMusic() {
    #if os(macOS)
    app.tabs["天干地支"].click()
    app.tables.cells.containing(.button, identifier: "地支，十二律呂，西洋調名").element.click()
    #else
    app.tabBars.firstMatch.buttons["天干地支"].tap()
    app.buttons["地支，十二律呂，西洋調名"].tap()
    #endif
    takingScreenShot()
  }

  func testTakeScreenshotOfMeridian() {
    #if os(macOS)
    app.tabs["天干地支"].click()
    app.tables.cells.containing(.button, identifier: "子午流注").element.click()
    #else
    app.tabBars.firstMatch.buttons["天干地支"].tap()
    app.buttons["子午流注"].tap()
    #endif

    takingScreenShot()
  }

  func takingScreenShot() {
    let screenshot = app.windows.firstMatch.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    attachment.lifetime = .keepAlways
    add(attachment)
  }
}
