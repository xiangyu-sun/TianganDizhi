//
//  MultiSelectionView.swift
//  LunarCalendar
//
//  Created by 孙翔宇 on 1/5/22.
//

import SwiftUI

import SwiftUI

// MARK: - MultiSelectionView

struct MultiSelectionView<Selectable: Identifiable & Hashable>: View {

  // MARK: Internal

  let options: [Selectable]
  let optionToString: (Selectable) -> String

  @Binding var selected: Set<Selectable>

  var body: some View {
    List {
      ForEach(options) { selectable in
        Button(action: { toggleSelection(selectable: selectable) }) {
          HStack {
            Text(optionToString(selectable)).foregroundColor(.primary)
            Spacer()
            if selected.contains(where: { $0.id == selectable.id }) {
              Image(systemName: "checkmark").foregroundColor(.accentColor)
            }
          }
        }.tag(selectable.id)
      }
    }
    #if os(iOS)
    .listStyle(GroupedListStyle())
    #else
    #endif
  }

  // MARK: Private

  private func toggleSelection(selectable: Selectable) {
    if let existingIndex = selected.firstIndex(where: { $0.id == selectable.id }) {
      selected.remove(at: existingIndex)
    } else {
      selected.insert(selectable)
    }
  }
}

// MARK: - MultiSelectionView_Previews

struct MultiSelectionView_Previews: PreviewProvider {
  struct IdentifiableString: Identifiable, Hashable {
    let string: String
    var id: String { string }
  }

  @State static var selected: Set<IdentifiableString> = Set(["A", "C"].map { IdentifiableString(string: $0) })

  static var previews: some View {
    NavigationView {
      MultiSelectionView(
        options: ["A", "B", "C", "D"].map { IdentifiableString(string: $0) },
        optionToString: { $0.string },
        selected: $selected)
    }
  }
}
