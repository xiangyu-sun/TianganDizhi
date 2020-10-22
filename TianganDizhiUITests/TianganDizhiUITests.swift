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
        XCUIApplication().tabBars["Tab Bar"].buttons["book"].tap()
        snapshot("testKownlegeScreen")
    }
    
    func testShichen() {
        app.tabBars["Tab Bar"].buttons["book"].tap()
        app/*@START_MENU_TOKEN@*/.tables.buttons["十天干"]/*[[".otherElements[\"knowledge\"].tables",".cells[\"十天干\"].buttons[\"十天干\"]",".buttons[\"十天干\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        snapshot("testShichen")
    }
}
