// bomberfish
// View+PlatformAppropriateToggle.swift – iCeleste
// created on 2023-12-31

import SwiftUI

struct PlatformAppropriateToggle: ViewModifier {
    func body(content: Content) -> some View {
        content
        #if os(macOS)
            .toggleStyle(.checkbox)
        #else
            .toggleStyle(.switch)
        #endif
    }
}

extension View {
    func platformAppropriateToggle() -> some View {
        modifier(PlatformAppropriateToggle())
    }
}
