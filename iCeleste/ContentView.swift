// bomberfish
// ContentView.swift – iCeleste
// created on 2023-12-30

import SwiftUI

struct ContentView: View {
    @AppStorage("reversedControls") var reversedControls: Bool = false
    @AppStorage("swagMode") var swagMode: Bool = true
    @State var screenUIImage: UIImage = .init(pixels: [PixelData(a: 255, r: 0, g: 0, b: 0)], width: 1, height: 1)!

    @State var dragOffset = CGSize.zero {
        willSet {
            librustic_set_btn(0, 0) // left
            librustic_set_btn(1, 0) // right
            librustic_set_btn(2, 0) // up
            librustic_set_btn(3, 0) // down
            if newValue.height < -15 {
                librustic_set_btn(2, 1)
            } else if newValue.height > 15 {
                librustic_set_btn(3, 1)
            }
            if newValue.width < -15 {
                librustic_set_btn(0, 1)
            } else if newValue.width > 15 {
                librustic_set_btn(1, 1)
            }
        }
    }

    func ptrToPixelData(pixels: UnsafeMutableRawPointer) -> [PixelData] {
        let buf = pixels.bindMemory(to: UInt8.self, capacity: 128*128)
        let arr = Array(UnsafeBufferPointer(start: buf, count: 128*128))
        return arr.map { el in
            PixelData(a: 255, r: pallete[Int(el)].0, g: pallete[Int(el)].1, b: pallete[Int(el)].2)
        }
    }

    func softButtonClick(_ btn: Int) {
        librustic_set_btn(CChar(btn), 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.033) {
            librustic_set_btn(CChar(btn), 0)
        }
        #if !os(macOS)
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred(intensity: 100)
        #endif
    }
    
    func playDpadHaptic(_ release: Bool = false) {
        #if !os(macOS)
        let generator = UIImpactFeedbackGenerator(style: release ? .medium : .light)
        generator.impactOccurred(intensity: 100)
        #endif
    }

    @ViewBuilder
    var dpad: some View {
        VStack(alignment: .center) {
            Button("", systemImage: "arrow.up") {}
                .pressAction {
                    librustic_set_btn(2, 1)
                    playDpadHaptic()
                } onRelease: {
                    librustic_set_btn(2, 0)
                    playDpadHaptic(true)
                }
                .epicButton()
            HStack {
                Button("", systemImage: "arrow.left") {}
                    .pressAction {
                        librustic_set_btn(0, 1)
                        playDpadHaptic()
                    } onRelease: {
                        librustic_set_btn(0, 0)
                        playDpadHaptic(true)
                    }
                    .epicButton()
                Spacer()
                Button("", systemImage: "arrow.right") {}
                    .pressAction {
                        librustic_set_btn(1, 1)
                        playDpadHaptic()
                    } onRelease: {
                        librustic_set_btn(1, 0)
                        playDpadHaptic(true)
                    }
                    .epicButton()
            }
            Button("", systemImage: "arrow.down") {}
                .pressAction {
                    librustic_set_btn(3, 1)
                    playDpadHaptic()
                } onRelease: {
                    librustic_set_btn(3, 0)
                    playDpadHaptic(true)
                }
                .epicButton()
        }
        .frame(width: 200, height: 100)
        .controlSize(.large)
    }

    @ViewBuilder
    var actions: some View {
        Group {
            Button("", systemImage: "arrow.up.to.line") {
                softButtonClick(4)
            }
            .epicButton(color: .blue)
            Button("", systemImage: "arrow.left.to.line.compact") {
                softButtonClick(5)
            }
            .epicButton(color: .red)
        }
        .controlSize(.large)
    }

    @ViewBuilder
    var buttons: some View {
        HStack {
            if reversedControls { actions } else { dpad }
            Spacer()
            if reversedControls { dpad } else { actions }
        }
    }
    
    @ViewBuilder
    var controls: some View {
        buttons
        Spacer()
        Toggle("Reversed Controls", isOn: $reversedControls)
        Toggle("Blurred background", isOn: $swagMode)
    }

    var body: some View {
            
            VStack {
                Image(uiImage: screenUIImage)
                    .interpolation(.none) // fix blurriness
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .task {
                        let map_p = UnsafeMutablePointer<CChar>(mutating: MAPDATA.utf8String)
                        let sprites_p = UnsafeMutablePointer<CChar>(mutating: SPRITES.utf8String)
                        let flags_p = UnsafeMutablePointer<CChar>(mutating: FLAGS.utf8String)
                        let fontatlas_p = UnsafeMutablePointer<CChar>(mutating: FONTATLAS.utf8String)
                        librustic_start(map_p, sprites_p, flags_p, fontatlas_p)
                        Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true, block: { _ in
                            librustic_next_tick()
                            let screen = ptrToPixelData(pixels: librustic_render_screen())
                            screenUIImage = UIImage(pixels: screen, width: 128, height: 128) ?? screenUIImage
                        })
                    }
                // TODO: Keyboard controls on macOS
                controls
            }
            .padding()
            .preferredColorScheme(swagMode ? .dark : .none) // blurred bg absolutely breaks everything in light mode
            .background {
                if swagMode {
                    Image(uiImage: screenUIImage)
                        .resizable()
                        .blur(radius: 16)
                        .ignoresSafeArea(.all)
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay {
                            Color.black.opacity(0.4)
                                .ignoresSafeArea(.all)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .animation(.easeInOut(duration: 0.35), value: swagMode)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: swagMode)
            .animation(.easeInOut(duration: 0.35), value: reversedControls)
        }
}

#Preview {
    ContentView()
}
