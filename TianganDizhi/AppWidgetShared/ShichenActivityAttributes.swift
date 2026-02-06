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
        public var nextShichenCountdown: String // e.g., "距離丑時還有 45 分鐘"
        
        public init(currentDate: Date, nextShichenCountdown: String = "") {
            self.currentDate = currentDate
            self.nextShichenCountdown = nextShichenCountdown
        }
    }
    
    // Static content (empty for this use case since everything is date-derived)
    public init() {}
}
#endif
