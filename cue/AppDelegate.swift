//
//  AppDelegate.swift
//  cue
//
//  Created by Michael Yang on 3/20/25.
//
import SwiftUI
import Cocoa

let _width = 350
let _height = 300

// App Delegate
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem?.button {
            statusButton.image = NSImage(systemSymbolName: "text.bubble", accessibilityDescription: "Cue")
            statusButton.action = #selector(togglePopover)
        }
        
        // Create the popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: _width, height: _height)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        self.popover = popover
    }
    
    @objc func togglePopover() {
        if let popover = popover {
            if popover.isShown {
                popover.close()
            } else {
                if let statusBarButton = statusItem?.button {
                    popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: .minY)
                    
                    // Make the app active
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
            }
        }
    }
}
