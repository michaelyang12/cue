//
//  cueApp.swift
//  cue
//
//  Created by Michael Yang on 3/19/25.
//

import SwiftUI
import Cocoa

@main
struct cueApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}


// Info.plist additions:
// <key>LSUIElement</key>
// <true/>
