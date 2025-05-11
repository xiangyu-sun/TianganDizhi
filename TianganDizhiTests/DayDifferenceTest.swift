//
//  DayDifferenceTest.swift
//  TianganDizhiTests
//
//  Created by Xiangyu Sun on 11/5/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//

import Testing
import Foundation
import ChineseAstrologyCalendar
import Astral

struct DayDifferenceTest {
  
  @Test func dayDifference() async throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 60)!
    let componentinEU = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: 2025,month: 5 ,day: 11, hour: 12,minute: 12)
    
    let dateInEU = try #require(componentinEU.date)
    
    let nextDate = preciseNextSolarTermDate(from: dateInEU, iterations: 5)
    
    var calendarChina = Calendar(identifier: .gregorian)
    calendarChina.timeZone = TimeZone(secondsFromGMT: 60 * 60 * 8)!
    

    let date1 = calendarChina.startOfDay(for: dateInEU)
    let date2 = calendarChina.startOfDay(for: nextDate)
    
    let diff = calendarChina.dateComponents([.day], from: date1, to: date2).day ?? 0
    
    #expect(diff == 10)
    
  }
  
  @Test func dayDifferenceGMT8() async throws {
    var calendarChina = Calendar(identifier: .gregorian)
    calendarChina.timeZone = TimeZone(secondsFromGMT: 60 * 60 * 8)!
    
    let componentinEU = DateComponents(calendar: calendarChina, timeZone: calendarChina.timeZone, year: 2025,month: 5 ,day: 11, hour: 12,minute: 12)
    
    let dateInEU = try #require(componentinEU.date)
    
    let nextDate = preciseNextSolarTermDate(from: dateInEU, iterations: 5)
    

    let date1 = calendarChina.startOfDay(for: dateInEU)
    let date2 = calendarChina.startOfDay(for: nextDate)
    
    let diff = calendarChina.dateComponents([.day], from: date1, to: date2).day ?? 0
    
    #expect(diff == 10)
    
  }
  
}
