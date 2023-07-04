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
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
      // This measures how long it takes to launch your application.
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }
  
#if os(macOS)
  
#else
  
  func testTakeScreenshotOfMusic() {
    app.tabBars.firstMatch.buttons["十二辟卦"].tap()
    takingScreenShot()
  }
  
  func testTakeScreenshotOfMainWindow() {
    app.tabBars.firstMatch.buttons["天干地支"].tap()
    app.tabBars.firstMatch.buttons["十二地支"].tap()
    takingScreenShot()
  }
  
  func testTakeScreenshotOfMusic() {
    app.tabBars.firstMatch.buttons["天干地支"].tap()
    app.tabBars.firstMatch.buttons["地支，十二律呂，西洋調名"].tap()
    takingScreenShot()
  }
  
  func testTakeScreenshotOfMeridian() {
    app.tabBars.firstMatch.buttons["天干地支"].tap()
    app.tabBars.firstMatch.buttons["子午流注"].tap()
    takingScreenShot()
  }
#endif
  
  func takingScreenShot() {
    let screenshot = app.windows.firstMatch.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    attachment.lifetime = .keepAlways
    add(attachment)
  }
}
