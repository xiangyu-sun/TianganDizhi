//
//  FontProvider.swift
//  TianganDizhi
//
//  Created by Claude Code
//

import SwiftUI
import Combine

// MARK: - FontProvider

/// Provides reactive font management across the app and widgets
/// Watches UserDefaults for font preference changes and updates fonts accordingly
@MainActor
final class FontProvider: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var useSystemFont: Bool {
        didSet {
            // Sync to UserDefaults when changed programmatically
            Constants.sharedUserDefault?.set(useSystemFont, forKey: Constants.useSystemFont)
        }
    }
    
    // MARK: - Private Properties
    
    private var defaultsObserver: NSObjectProtocol?
    
    // MARK: - Initialization
    
    init() {
        // Initialize from UserDefaults
        self.useSystemFont = Constants.sharedUserDefault?.bool(forKey: Constants.useSystemFont) ?? false
        
        // Observe UserDefaults changes (important for widgets to react to main app changes)
        defaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: Constants.sharedUserDefault,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            let newValue = Constants.sharedUserDefault?.bool(forKey: Constants.useSystemFont) ?? false
            if self.useSystemFont != newValue {
                self.useSystemFont = newValue
            }
        }
    }
    
    deinit {
        if let observer = defaultsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Computed Font Properties
    
    var titleFont: Font {
        #if os(watchOS)
        useSystemFont ? .title.bold() : .weiBeiTitleWatch
        #else
        useSystemFont ? .title.bold() : .weiBeiTitle
        #endif
    }
    
    var largeTitleFont: Font {
        useSystemFont ? .largeTitle.bold() : .weiBeiLargeTitle
    }
    
    var bodyFont: Font {
        useSystemFont ? .body.bold() : .weiBeiBody
    }
    
    var calloutFont: Font {
        useSystemFont ? .callout.bold() : .weiBeiCallOut
    }
    
    var footnoteFont: Font {
        useSystemFont ? .footnote.bold() : .weiBeiFootNote
    }
    
    var headlineFont: Font {
        useSystemFont ? .headline.bold() : .weiBeiHeadline
    }
    
    var title2Font: Font {
        useSystemFont ? .title2.bold() : .weiBeiTitle2
    }
    
    var title3Font: Font {
        useSystemFont ? .title3.bold() : .weiBeiTitle3
    }
}

// MARK: - FontProvider Environment Key

private struct FontProviderEnvironmentKey: EnvironmentKey {
    static let defaultValue: FontProvider = FontProvider()
}

extension EnvironmentValues {
    var fontProvider: FontProvider {
        get { self[FontProviderEnvironmentKey.self] }
        set { self[FontProviderEnvironmentKey.self] = newValue }
    }
}
