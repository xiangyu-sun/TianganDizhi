//
//  Date+ShichenProgress.swift
//  TianganDizhi
//
//  Created by Claude Code
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import Foundation
import ChineseAstrologyCalendar

extension Date {
    /// Calculate progress through the current Ke (0.0 to 1.0)
    var keProgress: Double {
        guard self.shichen != nil else { return 0.0 }
        
        // Each Shichen is 2 hours (120 minutes), divided into 8 Ke
        let shichenMinutes: Double = 120.0
        let keMinutes: Double = shichenMinutes / 8.0 // 15 minutes per Ke
        
        // Get current time components
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: self)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        // Convert to total minutes in day
        let totalMinutesNow = Double(hour * 60 + minute) + Double(second) / 60.0
        
        // Calculate start of current Shichen in minutes
        // Shichen starts at odd hours: 23, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21
        let shichenStartHour = (hour % 2 == 1) ? hour : hour - 1
        let adjustedStartHour = (shichenStartHour < 0) ? 23 : shichenStartHour
        let shichenStartMinute = Double(adjustedStartHour * 60)
        
        // Minutes into current Shichen
        var minutesIntoShichen = totalMinutesNow - shichenStartMinute
        if minutesIntoShichen < 0 {
            minutesIntoShichen += 1440 // Add 24 hours if wrapped
        }
        
        // Calculate which Ke we're in and progress within it
        // This gives us a precise position regardless of library's Ke calculation
        let kePosition = minutesIntoShichen / keMinutes // e.g., 5.7 means 70% through 6th Ke
        let progressInCurrentKe = kePosition.truncatingRemainder(dividingBy: 1.0) // Get fractional part
        
        return min(max(progressInCurrentKe, 0.0), 1.0)
    }
    
    /// Calculate the exact Date when the next Shichen starts
    var nextShichenTime: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: self)
        let hour = components.hour ?? 0
        
        // Get current Shichen start hour (odd hour)
        let shichenStartHour = (hour % 2 == 1) ? hour : hour - 1
        let adjustedStartHour = (shichenStartHour < 0) ? 23 : shichenStartHour
        
        // Calculate next Shichen start hour (start + 2, wrapping at 24)
        let nextShichenStartHour = (adjustedStartHour + 2) % 24
        
        // Create date for next Shichen start
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        dateComponents.hour = nextShichenStartHour
        dateComponents.minute = 0
        dateComponents.second = 0
        
        guard let nextTime = calendar.date(from: dateComponents) else {
            return self
        }
        
        // If the time is in the past (wrapped around midnight), add a day
        if nextTime < self {
            return calendar.date(byAdding: .day, value: 1, to: nextTime) ?? nextTime
        }
        
        return nextTime
    }
    
    /// Calculate countdown string to next Shichen
    var nextShichenCountdown: String {
        guard let currentShichen = self.shichen else { return "" }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: self)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        // Get current Shichen start hour (odd hour)
        let shichenStartHour = (hour % 2 == 1) ? hour : hour - 1
        let adjustedStartHour = (shichenStartHour < 0) ? 23 : shichenStartHour
        
        // Calculate end hour (start + 2, wrapping at 24)
        let shichenEndHour = (adjustedStartHour + 2) % 24
        
        // Calculate minutes until end
        var minutesUntilEnd: Int
        if hour < shichenEndHour {
            minutesUntilEnd = (shichenEndHour - hour - 1) * 60 + (60 - minute)
        } else {
            // Handle wrap around midnight
            minutesUntilEnd = (24 - hour + shichenEndHour - 1) * 60 + (60 - minute)
        }
        
        // Adjust for seconds
        if second > 0 && minutesUntilEnd > 0 {
            minutesUntilEnd -= 1
        }
        
        let nextShichen = currentShichen.dizhi.next
        
        if minutesUntilEnd < 60 {
            return "距離\(nextShichen.displayHourText)還有 \(minutesUntilEnd) 分鐘"
        } else {
            let hours = minutesUntilEnd / 60
            let mins = minutesUntilEnd % 60
            if mins == 0 {
                return "距離\(nextShichen.displayHourText)還有 \(hours) 小時"
            } else {
                return "距離\(nextShichen.displayHourText)還有 \(hours) 小時 \(mins) 分鐘"
            }
        }
    }
}
