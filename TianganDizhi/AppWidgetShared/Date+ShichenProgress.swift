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
        guard let shichen = self.shichen else { return 0.0 }
        
        // Each Shichen is 2 hours = 120 minutes
        // Each Ke is 1/8 of a Shichen = 15 minutes
        let keMinutes: Double = 15.0
        let currentKe = shichen.currentKe
        
        // Calculate minutes into current Ke
        // currentKe ranges from 1 to 8
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .second], from: self)
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        // Get the minute within the 120-minute Shichen cycle
        let minuteInShichen = minute % 120
        
        // Calculate which Ke we're in and progress
        let keStartMinute = Double(currentKe - 1) * keMinutes
        let minutesIntoKe = Double(minuteInShichen) - keStartMinute + Double(second) / 60.0
        let progress = minutesIntoKe / keMinutes
        
        return min(max(progress, 0.0), 1.0)
    }
    
    /// Calculate countdown string to next Shichen
    var nextShichenCountdown: String {
        guard let currentShichen = self.shichen else { return "" }
        
        // Calculate minutes until next Shichen (2 hours from start of current Shichen)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .second], from: self)
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        // Each Shichen is 120 minutes
        let minuteInShichen = minute % 120
        let minutesUntilEnd = 120 - minuteInShichen - (second > 0 ? 1 : 0)
        
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
