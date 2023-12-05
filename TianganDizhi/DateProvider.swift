//
//  DateProvider.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 28/10/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import Combine
import SwiftUI
 
final class DateProvider: ObservableObject {

  // MARK: Lifecycle

  init() {
    Timer.publish(every: 1, on: .main, in: .common).autoconnect().map { _ in Date() }.assign(to: &$currentDate)
  }

  // MARK: Internal

  @Published
  var currentDate = Date()
}
