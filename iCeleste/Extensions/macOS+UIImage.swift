// bomberfish
// macOS+UIImage.swift – iCeleste
// created on 2023-12-30

import SwiftUI

#if os(macOS)
typealias UIImage = NSImage

extension Image {
  init(uiImage: UIImage) {
        self.init(nsImage: uiImage)
    }
}
#endif
