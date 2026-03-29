//
//  MultiSelector.swift
//  LunarCalendar
//
//  Created by 孙翔宇 on 1/5/22.
//

import SwiftUI

// MARK: - MultiSelector

struct MultiSelector<LabelView: View, Selectable: Identifiable & Hashable & Comparable>: View {

  // MARK: Internal

  let label: LabelView
  let options: [Selectable]
  let optionToString: (Selectable) -> String

  var selected: Binding<Set<Selectable>>

  var body: some View {
    NavigationLink(destination: multiSelectionView()) {
      HStack {
        label
        Spacer()
        Text(formattedSelectedListString)
          .foregroundStyle(.gray)
          .multilineTextAlignment(.trailing)
      }
    }
  }

  // MARK: Private

  private var formattedSelectedListString: String {
    ListFormatter.localizedString(byJoining: selected.wrappedValue.sorted().map { optionToString($0) })
  }

  private func multiSelectionView() -> some View {
    MultiSelectionView(
      options: options,
      optionToString: optionToString,
      selected: selected)
  }
}

#Preview {
  struct IdentifiableString: Identifiable, Hashable, Comparable {
    static func <(lhs: IdentifiableString, rhs: IdentifiableString) -> Bool {
      lhs.string < rhs.string
    }
    let string: String
    var id: String { string }
  }

  struct PreviewWrapper: View {
    @State var selected: Set<IdentifiableString> = Set(["A", "C"].map { IdentifiableString(string: $0) })
    var body: some View {
      NavigationView {
        Form {
          MultiSelector<Text, IdentifiableString>(
            label: Text("Multiselect"),
            options: ["A", "B", "C", "D"].map { IdentifiableString(string: $0) },
            optionToString: { $0.string },
            selected: $selected)
        }.navigationTitle("Title")
      }
    }
  }
  return PreviewWrapper()
}
