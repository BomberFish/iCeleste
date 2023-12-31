// bomberfish
// ContentView.swift – iCeleste
// created on 2023-12-30

import SwiftUI
import SwiftUIBackports

func playActionHaptic() {
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

struct ContentView: View {
    @AppStorage("reversedControls") var reversedControls: Bool = false
    @AppStorage("reversedActions") var reversedActions: Bool = false
    @AppStorage("swagMode") var swagMode: Bool = true
    @AppStorage("swagMode") var swagLevel: Double = 0.2
    @State var screenUIImage: UIImage = .init(pixels: [PixelData(a: 255, r: 0, g: 0, b: 0)], width: 1, height: 1)!
    @State var showingSettings = false
    func ptrToPixelData(pixels: UnsafeMutableRawPointer) -> [PixelData] {
        let buf = pixels.bindMemory(to: UInt8.self, capacity: 128*128)
        let arr = Array(UnsafeBufferPointer(start: buf, count: 128*128))
        return arr.map { el in
            PixelData(a: 255, r: pallete[Int(el)].0, g: pallete[Int(el)].1, b: pallete[Int(el)].2)
        }
    }

    func softButtonClick(_ btn: Int) {
        librustic_set_btn(CChar(btn), 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 / 30.0) {
            librustic_set_btn(CChar(btn), 0)
        }
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
            Button("", systemImage: "arrow.up.to.line") {}
                .pressAction {
                    librustic_set_btn(4, 1)
                    playActionHaptic()
                } onRelease: {
                    librustic_set_btn(4, 0)
                }
                .epicButton(color: .blue)
            Button("", systemImage: "arrow.left.to.line.compact") {}
                .pressAction {
                    librustic_set_btn(5, 1)
                    playActionHaptic()
                } onRelease: {
                    librustic_set_btn(5, 0)
                }
                .epicButton(color: .red)
        }
        .controlSize(.large)
    }

    @ViewBuilder
    var actionsReversed: some View {
        Group {
            Button("", systemImage: "arrow.left.to.line.compact") {}
                .pressAction {
                    librustic_set_btn(5, 1)
                    playActionHaptic()
                } onRelease: {
                    librustic_set_btn(5, 0)
                }
                .epicButton(color: .red)
            Button("", systemImage: "arrow.up.to.line") {}
                .pressAction {
                    librustic_set_btn(4, 1)
                    playActionHaptic()
                } onRelease: {
                    librustic_set_btn(4, 0)
                }
                .epicButton(color: .blue)
        }
        .controlSize(.large)
    }

    @ViewBuilder
    var buttons: some View {
        HStack {
            if reversedControls { if reversedActions { actionsReversed } else { actions } } else { dpad }
            Spacer()
            if reversedControls { dpad } else { if reversedActions { actionsReversed } else { actions } }
        }
    }

    @ViewBuilder
    var controls: some View {
        Spacer()
        buttons
        Spacer()
        Button("Settings", systemImage: "gear") {
            showingSettings.toggle()
        }
        .controlSize(.large)
        .buttonStyle(.bordered)
        .tint(.accentColor)
    }

    @ViewBuilder
    var background: some View {
        #if os(macOS)
        let bounds: CGRect = NSApplication.shared.windows.first?.contentView?.bounds ?? .zero
        #else
        let bounds: CGRect = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.bounds ?? .zero
        #endif
        if swagMode {
            Image(uiImage: screenUIImage)
                .resizable()
                .blur(radius: 16)
                .ignoresSafeArea(.all)
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: bounds.width, maxWidth: .infinity, minHeight: bounds.height, maxHeight: .infinity)
                .overlay {
                    Color.black.opacity(1 - swagLevel)
                        .ignoresSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .animation(.easeInOut(duration: 0.35), value: swagMode)
        }
    }
    
    var body: some View {
        VStack {
            Image(uiImage: screenUIImage)
                .interpolation(.none) // fix blurriness
                .resizable()
                .aspectRatio(contentMode: .fit)
            #if !os(macOS)
                .padding()
            #endif
                .task {
//                    timer.connect()
                }
                .onReceive(timer) { tick in
                    let screen = ptrToPixelData(pixels: librustic_render_screen())
                    screenUIImage = UIImage(pixels: screen, width: 128, height: 128) ?? screenUIImage
                }
            #if !os(macOS)
            controls
            #endif
        }
        #if !os(macOS)
        .padding()
        #endif
        .background {
            background
        }
        #if !os(macOS)
        .sheet(isPresented: $showingSettings) {
            if #available(iOS 16.0, *) {
                SettingsView()
                    .presentationDetents([.medium, .large])
            } else {
                SettingsView()
                    .backport.presentationDetents([.medium, .large])
            }
        }
        #endif
        .animation(.easeInOut(duration: 0.35), value: swagMode)
        .animation(.easeInOut(duration: 0.35), value: reversedControls)
    }
}

struct SettingsView: View {
    @AppStorage("reversedControls") var reversedControls: Bool = false
    @AppStorage("reversedActions") var reversedActions: Bool = false
    @AppStorage("swagMode") var swagMode: Bool = true
    @AppStorage("swagMode") var swagLevel: Double = 0.25

    @Environment(\.dismiss) var d
    var body: some View {
        VStack {
            #if !os(macOS)
            Text("Settings")
                .bold()
                .padding(.top, 20)
            #endif
            List {
                Section("Controls") {
                    #if !os(macOS)
                    Toggle("Reversed Controls", isOn: $reversedControls)
                    #endif
                    Toggle("Swap Dash and Jump", isOn: $reversedActions)
                }
                .platformAppropriateToggle()
                Section("Appearance") {
                    Toggle("Blurred background", isOn: $swagMode)
                    if swagMode {
                        HStack {
                            Text("Intensity")
                            Slider(value: $swagLevel, in: 0 ... 1, step: 0.1) {}
                                .onChange(of: swagLevel) { _ in
                                    playDpadHaptic()
                                }
                            Button(action: { swagLevel = 0.2 }, label: {
                                Image(systemName: "arrow.counterclockwise")
                            })
                        }
                    }
                }
            }
            #if !os(macOS)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        d()
                    }
                }
            }
            #endif
        }
        #if !os(macOS)
        .background(Color(UIColor.systemGroupedBackground))
        #endif
        .tint(.accentColor)
    }
}

#Preview {
    ContentView()
}
