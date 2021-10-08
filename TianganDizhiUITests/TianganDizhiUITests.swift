//
//  TianganDizhiUITests.swift
//  TianganDizhiUITests
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import XCTest

class TianganDizhiUITests: XCTestCase {

    var app: XCUIApplication!
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.

        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testLaunch() {
        snapshot("launch")
    }
    
    func testKownlegeScreen() {
        app.tabBars.firstMatch.buttons["天干地支"].tap()
        snapshot("testKownlegeScreen")
    }
    
    func testJingluo() {
        app.tabBars.firstMatch.buttons["天干地支"].tap()
        app.tables.buttons["時辰與經絡"].tap()
        snapshot("testJingluo")
    }
}
