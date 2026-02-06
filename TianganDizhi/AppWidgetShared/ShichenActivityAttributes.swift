//
//  ShichenActivityAttributes.swift
//  TianganDizhi
//
//  Created by Claude Code
//  Copyright © 2026 孙翔宇. All rights reserved.
//

#if canImport(ActivityKit)
import ActivityKit
import Foundation

// MARK: - ShichenActivityAttributes

public struct ShichenActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic content that changes over time
        public var currentDate: Date
        public var keProgress: Double // 0.0 to 1.0 representing progress through current Ke
        public var nextShichenCountdown: String // e.g., "距离丑时还有 45 分钟"
        
        public init(currentDate: Date, keProgress: Double = 0.0, nextShichenCountdown: String = "") {
            self.currentDate = currentDate
            self.keProgress = keProgress
            self.nextShichenCountdown = nextShichenCountdown
        }
    }
    
    // Static content (empty for this use case since everything is date-derived)
    public init() {}
}
#endif
