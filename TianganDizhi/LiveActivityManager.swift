//
//  LiveActivityManager.swift
//  TianganDizhi
//
//  Created by Claude Code
//  Copyright © 2026 孙翔宇. All rights reserved.
//

#if canImport(ActivityKit) && os(iOS)
import ActivityKit
#endif
import Foundation
import SwiftUI

@MainActor
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    #if canImport(ActivityKit) && os(iOS)
    private var _currentActivity: Any?
    
    @available(iOS 16.1, *)
    var currentActivity: Activity<ShichenActivityAttributes>? {
        get { _currentActivity as? Activity<ShichenActivityAttributes> }
        set { _currentActivity = newValue }
    }
    #endif
    private var activityStartTime: Date?
    private var restartCheckTimer: Timer?
    private var updateTask: Task<Void, Never>?
    
    var isActivityRunning: Bool {
        #if canImport(ActivityKit) && os(iOS)
        if #available(iOS 16.1, *) {
            return currentActivity != nil && currentActivity?.activityState == .active
        }
        #endif
        return false
    }
    
    private init() {}
    
    // MARK: - Start Live Activity
    
    func startLiveActivity() async throws {
        #if canImport(ActivityKit) && os(iOS)
        guard #available(iOS 16.2, *) else {
            throw LiveActivityError.notEnabled
        }
        
        // Check if Live Activities are supported
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw LiveActivityError.notEnabled
        }
        
        // End existing activity if any
        if let existingActivity = currentActivity {
            await existingActivity.end(nil, dismissalPolicy: .immediate)
        }
        
        // Create initial content state
        let now = Date()
        let initialContentState = ShichenActivityAttributes.ContentState(
            currentDate: now,
            nextShichenCountdown: now.nextShichenCountdown
        )
        
        // Set stale date to 1 minute from now to trigger system refresh
        let staleDate = Calendar.current.date(byAdding: .minute, value: 1, to: now)
        
        // Create activity content
        let activityContent = ActivityContent(
            state: initialContentState,
            staleDate: staleDate
        )
        
        // Start the Live Activity
        do {
            let activity = try Activity<ShichenActivityAttributes>.request(
                attributes: ShichenActivityAttributes(),
                content: activityContent,
                pushType: nil
            )
            
            currentActivity = activity
            activityStartTime = Date()
            
            // Start background task to update activity
            startBackgroundUpdates()
            
            // Start timer to check for automatic restart (check every hour)
            startRestartCheckTimer()
            
        } catch {
            throw LiveActivityError.failedToStart(error)
        }
        #else
        throw LiveActivityError.notEnabled
        #endif
    }
    
    // MARK: - Update Live Activity
    
    private func startBackgroundUpdates() {
        // Start observing app lifecycle to update when app becomes active
        #if canImport(ActivityKit) && os(iOS)
        guard #available(iOS 16.1, *) else { return }
        
        // Start a task that updates periodically while the app is running
        updateTask = Task { [weak self] in
            guard let self = self else { return }
            
            // Initial immediate update
            await self.updateLiveActivity()
            
            while !Task.isCancelled {
                // Wait 60 seconds
                try? await Task.sleep(nanoseconds: 60_000_000_000)
                
                if Task.isCancelled { break }
                
                // Check if activity is still running
                guard await self.isActivityRunning else { break }
                
                // Update the activity
                print("🔄 Updating Live Activity at \(Date())")
                await self.updateLiveActivity()
            }
        }
        #endif
    }
    
    private func stopBackgroundUpdates() {
        updateTask?.cancel()
        updateTask = nil
    }
    
    // Call this when app becomes active to refresh the activity
    func refreshActivity() async {
        await updateLiveActivity()
    }
    
    private func updateLiveActivity() async {
        #if canImport(ActivityKit) && os(iOS)
        guard #available(iOS 16.2, *) else { return }
        guard let activity = currentActivity,
              activity.activityState == .active else {
            return
        }
        
        let now = Date()
        let updatedContentState = ShichenActivityAttributes.ContentState(
            currentDate: now,
            nextShichenCountdown: now.nextShichenCountdown
        )
        
        // Set next stale date to 1 minute from now
        let staleDate = Calendar.current.date(byAdding: .minute, value: 1, to: now)
        
        let updatedContent = ActivityContent(
            state: updatedContentState,
            staleDate: staleDate
        )
        
        await activity.update(updatedContent)
        #endif
    }
    
    // MARK: - Auto-Restart Logic
    
    private func startRestartCheckTimer() {
        // Stop existing timer if any
        restartCheckTimer?.invalidate()
        
        // Check every hour if we need to restart
        restartCheckTimer = Timer.scheduledTimer(withTimeInterval: 3600.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkAndRestartIfNeeded()
            }
        }
        
        if let timer = restartCheckTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func checkAndRestartIfNeeded() async {
        #if canImport(ActivityKit) && os(iOS)
        guard #available(iOS 16.2, *) else { return }
        
        guard let startTime = activityStartTime else { return }
        
        // Calculate how long the activity has been running
        let runningDuration = Date().timeIntervalSince(startTime)
        
        // If running for more than 11 hours, restart it
        // (11 hours to give buffer before the 12-hour limit)
        if runningDuration > (11 * 3600) {
            // End current activity
            await endLiveActivity()
            
            // Start a new one
            try? await startLiveActivity()
        }
        #endif
    }
    
    private func stopRestartCheckTimer() {
        restartCheckTimer?.invalidate()
        restartCheckTimer = nil
    }
    
    // MARK: - End Live Activity
    
    func endLiveActivity() async {
        stopBackgroundUpdates()
        stopRestartCheckTimer()
        activityStartTime = nil
        
        #if canImport(ActivityKit) && os(iOS)
        guard #available(iOS 16.2, *) else { return }
        guard let activity = currentActivity else {
            return
        }
        
        let now = Date()
        let finalContentState = ShichenActivityAttributes.ContentState(
            currentDate: now,
            nextShichenCountdown: now.nextShichenCountdown
        )
        
        let finalContent = ActivityContent(
            state: finalContentState,
            staleDate: nil
        )
        
        await activity.end(finalContent, dismissalPolicy: .immediate)
        currentActivity = nil
        #endif
    }
    
    // MARK: - Toggle
    
    func toggleLiveActivity() async throws {
        if isActivityRunning {
            await endLiveActivity()
        } else {
            try await startLiveActivity()
        }
    }
}

// MARK: - LiveActivityError

enum LiveActivityError: LocalizedError {
    case notEnabled
    case failedToStart(Error)
    
    var errorDescription: String? {
        switch self {
        case .notEnabled:
            return "Live Activities are not enabled. Please enable them in Settings."
        case .failedToStart(let error):
            return "Failed to start Live Activity: \(error.localizedDescription)"
        }
    }
}
