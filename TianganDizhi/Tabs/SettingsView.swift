//
//  SettingsView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 22/12/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - SettingsView

struct SettingsView: View {
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false
  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false
  @AppStorage(Constants.displayMoonPhaseOnWidgets, store: Constants.sharedUserDefault)
  var displayMoonPhaseOnWidgets = false
  @AppStorage(Constants.useGTM8, store: Constants.sharedUserDefault)
  var useGTM8 = false
  @AppStorage(Constants.piGuaRotationEnabled, store: Constants.sharedUserDefault)
  var piGuaRotationEnabled = false
  @AppStorage(Constants.useSystemFont, store: Constants.sharedUserDefault)
  var useSystemFont = false
  @AppStorage(Constants.backgroundStyle, store: Constants.sharedUserDefault)
  var backgroundStyle = 0

  @Environment(\.footnote) var footnote
  @EnvironmentObject var fontProvider: FontProvider
  @EnvironmentObject var settingsManager: SettingsManager

  @State private var showReloadToast = false

  var body: some View {
    Form {
      Section {
        ShareLink(item: Date.now.shichenShareText) {
          Label("分享今日時辰資訊", systemImage: "square.and.arrow.up")
        }
      }
      Section(header: Text("春節氣氛組件設置")) {
        Toggle(isOn: $springFestiveBackgroundEnabled) {
          VStack(alignment: .leading, spacing: 2) {
            Text("組件紅底")
            Text("小組件在春節期間使用紅色背景")
              .font(footnote)
              .foregroundStyle(.secondary)
          }
        }
        .accessibilityHint("開啟後小組件在春節期間顯示紅色背景")
        Toggle(isOn: $springFestiveForegroundEnabled) {
          VStack(alignment: .leading, spacing: 2) {
            Text("組件夜間模式使用黑字")
            Text("夜間深色模式下組件文字顯示為黑色")
              .font(footnote)
              .foregroundStyle(.secondary)
          }
        }
        .accessibilityHint("開啟後夜間深色模式下組件文字顯示為黑色")
      }
      Section(header: Text("顯示設置")) {
        if #available(iOS 17.0, macOS 14.0, *) {
          Picker(selection: $backgroundStyle) {
            Text("宣紙").tag(0)
            Text("大理石").tag(1)
          } label: {
            VStack(alignment: .leading, spacing: 2) {
              Text("背景風格")
              Text("宣紙質感或大理石紋理")
                .font(footnote)
                .foregroundStyle(.secondary)
            }
          }
          .onChange(of: backgroundStyle) { _ in reloadWidgets() }
        }
        Toggle(isOn: $useSystemFont) {
          VStack(alignment: .leading, spacing: 2) {
            Text("使用系統字體")
            Text("以系統預設字體取代魏碑字體")
              .font(footnote)
              .foregroundStyle(.secondary)
          }
        }
        .accessibilityHint("開啟後全App使用系統字體而非魏碑字體")
        Toggle(isOn: $displayMoonPhaseOnWidgets) {
          VStack(alignment: .leading, spacing: 2) {
            Text("組件顯示月相")
            Text("小組件上顯示當日月相符號")
              .font(footnote)
              .foregroundStyle(.secondary)
          }
        }
        .accessibilityHint("開啟後小組件會顯示當日月相符號")
        Toggle(isOn: $useTranditionalNaming) {
          VStack(alignment: .leading, spacing: 2) {
            Text("顯示傳統名稱")
            Text("時辰及節氣使用傳統古稱")
              .font(footnote)
              .foregroundStyle(.secondary)
          }
        }
        .accessibilityHint("開啟後時辰及節氣顯示傳統古稱")
        Toggle(isOn: $piGuaRotationEnabled) {
          VStack(alignment: .leading, spacing: 2) {
            Text("十二辟卦文字方向配圓弧")
            Text("辟卦圓形圖中文字沿圓弧方向排列")
              .font(footnote)
              .foregroundStyle(.secondary)
          }
        }
        .accessibilityHint("開啟後辟卦圓形圖的文字會沿圓弧方向排列")
      }
      Section(header: Text("地區與日曆")) {
        Toggle(isOn: $useGTM8) {
          VStack(alignment: .leading, spacing: 2) {
            Text("節日使用東八區時間")
            Text("海外用戶：節日以東八區時間（UTC+8）計算")
              .font(footnote)
              .foregroundStyle(.secondary)
          }
        }
        .accessibilityHint("海外用戶開啟後節日以中國標準時間計算")
      }
    }
    .font(fontProvider.bodyFont)
    .navigationTitle(Text("設置"))
    .overlay(alignment: .bottom) {
      if showReloadToast {
        Text("小組件已更新")
          .font(footnote)
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(.regularMaterial, in: Capsule())
          .padding(.bottom, 24)
          .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .animation(.easeInOut(duration: 0.3), value: showReloadToast)
    .onChange(of: useSystemFont) { value in
      fontProvider.useSystemFont = value
      settingsManager.useSystemFont = value
      reloadWidgets()
    }
    .onChange(of: springFestiveBackgroundEnabled) { _ in reloadWidgets() }
    .onChange(of: useTranditionalNaming) { _ in reloadWidgets() }
    .onChange(of: springFestiveForegroundEnabled) { _ in reloadWidgets() }
    .onChange(of: useGTM8) { _ in reloadWidgets() }
    .onChange(of: displayMoonPhaseOnWidgets) { _ in reloadWidgets() }
  }

  private func reloadWidgets() {
    WidgetCenter.shared.reloadAllTimelines()
    showReloadToast = true
    Task {
      try? await Task.sleep(nanoseconds: 1_500_000_000)
      showReloadToast = false
    }
  }
}

#Preview {
  SettingsView()
    .environmentObject(FontProvider())
    .environmentObject(SettingsManager.shared)
}
