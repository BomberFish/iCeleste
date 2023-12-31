// bomberfish
// View+epicButton.swift – iCeleste
// created on 2023-12-30

import SwiftUI

struct EpicButton: ViewModifier {
//    @Environment(\.colorScheme) var colorScheme
    let color: Color
    func body(content: Content) -> some View {
        content
            .foregroundColor(.primary)
            .tint(color)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
    }
}

extension View {
  func epicButton(color: Color = Color(.secondarySystemBackground))
    -> some View {
      modifier(EpicButton(color: color))
  }
}
