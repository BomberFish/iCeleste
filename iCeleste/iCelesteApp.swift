// bomberfish
// iCelesteApp.swift – iCeleste
// created on 2023-12-30

import SwiftUI

@main
struct iCelesteApp: App {
    #if os(macOS)
    init() {
        KBControlMgr.start() // start monitoring for keyboard input
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { _ in return nil } // silence beep
    }
    #endif
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
#if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
