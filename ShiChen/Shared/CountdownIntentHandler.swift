//
//  CountdownIntentHandler.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 23/1/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import Intents
import ChineseAstrologyCalendar

class CountdownIntentHandler: INExtension, CountDownIntentConfigurationIntentHandling {
  
  func resolveParameter(for intent: CountDownIntentConfigurationIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
    completion(.success(with: intent.parameter ?? Date().dateComponentsFromCurrentCalendar))
  }
  
  
  func resolveTitle(for intent: CountDownIntentConfigurationIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    let title = (intent.title ?? intent.parameter?.date?.displayStringOfChineseYearMonthDateWithZodiac) ?? ""
    completion(.success(with: title))
  }
  
    
}
