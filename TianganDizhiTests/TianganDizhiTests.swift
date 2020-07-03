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

    func testNianGanToNotbeNil() {
        XCTAssertNotNil(Date().nianGan)
    }
    
    func testNianGanList() {
        for i in 1...10 {
            XCTAssertNotNil(Tiangan(rawValue: i))
        }
    }
    func testNianZhiToNotbeNil() {
        XCTAssertNotNil(Date().nianZhi)
    }
    
    func testNianZhiList() {
        for i in 1...12 {
            XCTAssertNotNil(Dizhi(rawValue: i))
        }
    }
}
