// bomberfish
// KBControlMgr.swift – iCeleste
// created on 2023-12-31

import SwiftUI
import OSLog

class KBControlMgr {
    private static let pollingInterval: DispatchTimeInterval = .milliseconds(50)
    private static let pollingQueue = DispatchQueue.main
    
    static func start() {
        scheduleNextPoll(on: pollingQueue)
    }
    
    static var keyStates: [CGKeyCode: Bool] = [
        .kVK_LeftArrow: false, // left (0)
        .kVK_RightArrow: false, // right (1)
        .kVK_UpArrow: false, // up (2)
        .kVK_DownArrow: false, // down (3)
        .kVK_ANSI_X: false, // jump (4)
        .kVK_ANSI_Z: false // dash (5)
    ]
    
    static func dispatchKeyDown(_ key: CGKeyCode)
    {
        switch key {
        case .kVK_LeftArrow:
            librustic_set_btn(0, 1)
        case .kVK_RightArrow:
            librustic_set_btn(1, 1)
        case .kVK_UpArrow:
            librustic_set_btn(2, 1)
        case .kVK_DownArrow:
            librustic_set_btn(3, 1)
        case .kVK_ANSI_X:
            if UserDefaults.standard.bool(forKey: "reversedActions") {
                librustic_set_btn(5, 1)
            } else {
                librustic_set_btn(4, 1)
            }
        case .kVK_ANSI_Z:
            if UserDefaults.standard.bool(forKey: "reversedActions") {
                librustic_set_btn(4, 1)
            } else {
                librustic_set_btn(5, 1)
            }
        default:
            Logger().debug("ignoring keypress \(key)")
        }
    }
 
    static func dispatchKeyUp(_ key: CGKeyCode) {
        switch key {
        case .kVK_LeftArrow:
            librustic_set_btn(0, 0)
        case .kVK_RightArrow:
            librustic_set_btn(1, 0)
        case .kVK_UpArrow:
            librustic_set_btn(2, 0)
        case .kVK_DownArrow:
            librustic_set_btn(3, 0)
        case .kVK_ANSI_X:
            if UserDefaults.standard.bool(forKey: "reversedActions") {
                librustic_set_btn(5, 0)
            } else {
                librustic_set_btn(4, 0)
            }
        case .kVK_ANSI_Z:
            if UserDefaults.standard.bool(forKey: "reversedActions") {
                librustic_set_btn(4, 0)
            } else {
                librustic_set_btn(5, 0)
            }
        default:
            // ignore
            Logger().debug("ignoring keypress \(key)")
        }
    }
    
    private static func scheduleNextPoll(on queue: DispatchQueue) {
        queue.asyncAfter(deadline: .now() + pollingInterval) {
            pollKeyStates()
        }
    }
    
    static func pollKeyStates() {
        for (code, wasPressed) in keyStates {
            if code.isPressed {
                if !wasPressed {
                    dispatchKeyDown(code)
                    keyStates[code] = true
                }
            } else if wasPressed {
                dispatchKeyUp(code)
                keyStates[code] = false
            }
        }
        
        scheduleNextPoll(on: pollingQueue)
    }
}
