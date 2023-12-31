// bomberfish
// View+epicButton.swift – iCeleste
// created on 2023-12-30

import SwiftUI

struct EpicButton: ViewModifier {
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
    #if os(macOS)

    func epicButton(color: Color = Color(NSColor.windowBackgroundColor)) -> some View {
        modifier(EpicButton(color: color))
    }
    #else
    func epicButton(color: Color = Color(UIColor.secondarySystemBackground)) -> some View {
        modifier(EpicButton(color: color))
    }
    #endif
}
