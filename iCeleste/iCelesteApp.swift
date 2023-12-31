// bomberfish
// iCelesteApp.swift – iCeleste
// created on 2023-12-30

import SwiftUI

var isGameRunning = false
let timer = Timer.publish(every: 1.0/30.0, on: .main, in: .common).autoconnect()

@main
struct iCelesteApp: App {
    init() {
#if os(macOS)
        KBControlMgr.start() // start monitoring for keyboard input
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { _ in return nil } // silence beep
#endif
        let map_p = UnsafeMutablePointer<CChar>(mutating: MAPDATA.utf8String)
        let sprites_p = UnsafeMutablePointer<CChar>(mutating: SPRITES.utf8String)
        let flags_p = UnsafeMutablePointer<CChar>(mutating: FLAGS.utf8String)
        let fontatlas_p = UnsafeMutablePointer<CChar>(mutating: FONTATLAS.utf8String)
        librustic_start(map_p, sprites_p, flags_p, fontatlas_p)
    }
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(timer) {_ in
                    librustic_next_tick()
                }
        }
#if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
