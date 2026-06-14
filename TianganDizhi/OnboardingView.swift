//
//  OnboardingView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 14/06/26.
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {
  @AppStorage(Constants.hasCompletedOnboarding, store: Constants.sharedUserDefault)
  var hasCompletedOnboarding = false

  @AppStorage(Constants.useGTM8, store: Constants.sharedUserDefault)
  var useGTM8 = false

  private var isOverseasUser: Bool {
    TimeZone.current.secondsFromGMT() != 8 * 3600
  }

  var body: some View {
    TabView {
      OnboardingPage(
        symbol: "clock.fill",
        title: "歡迎使用時辰",
        description: "時辰是中國傳統的十二時辰計時系統，每個時辰對應兩小時。本App顯示當前時辰、星象及天氣資訊。")
      .tag(0)

      OnboardingPage(
        symbol: "leaf.fill",
        title: "二十四節氣",
        description: "節氣是中國傳統曆法中的二十四個特定時間點，標記季節變化。App會顯示當前及最近的節氣資訊。")
      .tag(1)

      OnboardingPage(
        symbol: "moon.stars.fill",
        title: "天干地支、卦與圖示",
        description: "「天干地支」分頁提供學習資料。「卦」分頁展示八卦與辟卦。「參考圖示」提供快速查閱表。")
      .tag(2)

      VStack(spacing: 28) {
        Image(systemName: "globe.asia.australia.fill")
          .font(.system(size: 60))
          .foregroundStyle(.secondary)
        if isOverseasUser {
          VStack(spacing: 12) {
            Text("時區設置")
              .font(.title2)
              .bold()
            Text("您似乎不在東八區（UTC+8），節日是否以東八區時間計算？")
              .font(.body)
              .multilineTextAlignment(.center)
              .foregroundStyle(.secondary)
              .padding(.horizontal, 16)
            Toggle(isOn: $useGTM8) {
              Text("使用東八區時間（UTC+8）")
            }
            .padding(.horizontal, 40)
          }
        }
        Button("開始使用") {
          hasCompletedOnboarding = true
        }
        .buttonStyle(.borderedProminent)
        .font(.body)
      }
      .padding()
      .tag(3)
    }
    .tabViewStyle(.page)
    #if !os(watchOS)
    .indexViewStyle(.page(backgroundDisplayMode: .always))
    #endif
  }
}

// MARK: - OnboardingPage

private struct OnboardingPage: View {
  let symbol: String
  let title: String
  let description: String

  var body: some View {
    VStack(spacing: 24) {
      Image(systemName: symbol)
        .font(.system(size: 60))
        .foregroundStyle(.secondary)
      Text(title)
        .font(.title2)
        .bold()
      Text(description)
        .font(.body)
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 32)
    }
    .padding()
  }
}

#Preview {
  OnboardingView()
}
