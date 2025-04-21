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
          .foregroundColor(.gray)
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

// MARK: - MultiSelector_Previews

struct MultiSelector_Previews: PreviewProvider {
  struct IdentifiableString: Identifiable, Hashable, Comparable {
    static func <(lhs: MultiSelector_Previews.IdentifiableString, rhs: MultiSelector_Previews.IdentifiableString) -> Bool {
      lhs.string < rhs.string
    }

    let string: String
    var id: String { string }
  }

  @State static var selected: Set<IdentifiableString> = Set(["A", "C"].map { IdentifiableString(string: $0) })

  static var previews: some View {
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
