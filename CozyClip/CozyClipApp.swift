import SwiftUI

@main
struct CozyClipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var clipboardManager = ClipboardManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            if let img = NSImage(systemSymbolName: "paperclip", accessibilityDescription: "CozyClip") {
                img.isTemplate = true
                button.image = img
            } else {
                button.title = "CC"
            }
            button.action = #selector(togglePopover(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 420)
        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = NSHostingController(
            rootView: ClipboardView(manager: clipboardManager)
        )

        // Hide dock icon after setup
        NSApp.setActivationPolicy(.accessory)
    }

    @objc func togglePopover(_ sender: Any?) {
        guard let event = NSApp.currentEvent, let button = statusItem.button else { return }

        if event.type == .rightMouseUp {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Quit CozyClip", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
            statusItem.menu = menu
            button.performClick(nil)
            // Clear menu so left click keeps working
            DispatchQueue.main.async { self.statusItem.menu = nil }
            return
        }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
