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

  /// Drives the step funnel. Where users stop is where onboarding loses them —
  /// and users who never finish rarely go on to install a widget.
  @State private var step = 0

  private static var widgetInstructions: String {
    #if os(macOS)
    "時辰、節氣、農曆無需打開App，一眼可見。在桌面按右鍵，選擇「編輯小工具」，搜尋「天干地支」即可加入。"
    #else
    "時辰、節氣、農曆無需打開App，一眼可見。長按主畫面空白處，點「編輯」→「加入小工具」，搜尋「天干地支」即可加入；鎖定畫面同樣適用。"
    #endif
  }

  private var isOverseasUser: Bool {
    TimeZone.current.secondsFromGMT() != 8 * 3600
  }

  var body: some View {
    TabView(selection: $step) {
      // Kept to one page: the old three reading pages were where half of the
      // people who started onboarding gave up.
      OnboardingPage(
        symbol: "clock.fill",
        title: "歡迎使用時辰",
        description: "以十二時辰、二十四節氣與天干地支，顯示當下的傳統曆法、星象及天氣。")
      .tag(0)

      // Widget users are the engaged ones — most sessions start from a widget
      // tap — so point new users at them before they leave onboarding.
      OnboardingPage(
        symbol: "square.grid.2x2.fill",
        title: "加入小組件",
        description: Self.widgetInstructions)
      .tag(1)

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
            .onChange(of: useGTM8) { value in
              AnalyticsService.log(.settingChanged(
                name: "\(Constants.useGTM8)_onboarding",
                value: String(value)))
            }
          }
        }
        Button("開始使用") {
          AnalyticsService.log(.onboardingCompleted)
          hasCompletedOnboarding = true
        }
        .buttonStyle(.borderedProminent)
        .font(.body)
      }
      .padding()
      .tag(2)
    }
    .onAppear {
      AnalyticsService.log(.onboardingStepViewed(step: step))
    }
    .onChange(of: step) { newStep in
      AnalyticsService.log(.onboardingStepViewed(step: newStep))
    }
    #if os(iOS)
    .tabViewStyle(.page)
    #if !os(watchOS)
    .indexViewStyle(.page(backgroundDisplayMode: .always))
    #endif
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
