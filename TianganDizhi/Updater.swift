//
//  Updater.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 25/08/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import UIKit

final class Updater: NSObject, ObservableObject {
    static let shared = Updater()
    
    private lazy var displayLink: CADisplayLink = {
        let displaylink = CADisplayLink(target: self, selector: #selector(updateFired(link:)))
        displaylink.preferredFramesPerSecond = 60
        
        return displaylink
    }()
    
    
    @Published private(set) var date: Date = Date()
    
    override init() {
        super.init()
        displayLink.add(to: .current, forMode: .default)
    }
    
    @objc
    func updateFired(link: CADisplayLink) {
        date = Date()
    }
    
}
