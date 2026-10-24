//
//  AppDelegate.swift
//  ProductiveSpagetti
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {

    private var windowDelegates: [ObjectIdentifier: WindowDelegate] = [:]

    func applicationDidFinishLaunching(_ notification: Notification) {
        installWindowCloseGuards()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // SwiftUI creates its windows after launch, so attach the guard again
        // once the application has an active window.
        installWindowCloseGuards()
    }

    private func installWindowCloseGuards() {
        for window in NSApplication.shared.windows where window.isVisible {
            let identifier = ObjectIdentifier(window)

            if windowDelegates[identifier] == nil {
                let delegate = WindowDelegate()
                window.delegate = delegate
                windowDelegates[identifier] = delegate
            }
        }
    }

    func applicationShouldTerminate(
        _ sender: NSApplication
    ) -> NSApplication.TerminateReply {

        checkPasscodeBeforeClosing()
    }

    private func checkPasscodeBeforeClosing()
        -> NSApplication.TerminateReply {

        let parentalControls =
            UserDefaults.standard.bool(forKey: "forChild")

        if !parentalControls {
            return .terminateNow
        }

        let savedPasscode =
            UserDefaults.standard.string(
                forKey: "lockpasscode"
            ) ?? ""

        let alert = NSAlert()

        alert.messageText = "Parental Controls"

        alert.informativeText =
            "Enter the 4-digit passcode to close Productive Spagetti."

        let field = NSSecureTextField(
            frame: NSRect(
                x: 0,
                y: 0,
                width: 220,
                height: 24
            )
        )

        field.placeholderString = "4-digit passcode"

        alert.accessoryView = field

        alert.addButton(withTitle: "Quit")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {

            if field.stringValue == savedPasscode {

                return .terminateNow

            } else {

                let error = NSAlert()

                error.messageText =
                    "Incorrect Passcode ❌"

                error.informativeText =
                    "You need the correct passcode to close the app."

                error.addButton(withTitle: "OK")

                error.runModal()

                return .terminateCancel
            }
        }

        return .terminateCancel
    }
}


// MARK: - Window Delegate

class WindowDelegate: NSObject, NSWindowDelegate {

    func windowShouldClose(
        _ sender: NSWindow
    ) -> Bool {

        let parentalControls =
            UserDefaults.standard.bool(
                forKey: "forChild"
            )

        // No parental controls = close normally
        if !parentalControls {
            return true
        }

        let savedPasscode =
            UserDefaults.standard.string(
                forKey: "lockpasscode"
            ) ?? ""

        let alert = NSAlert()

        alert.messageText =
            "Parental Controls"

        alert.informativeText =
            "Enter the 4-digit passcode to close Productive Spagetti."

        let field = NSSecureTextField(
            frame: NSRect(
                x: 0,
                y: 0,
                width: 220,
                height: 24
            )
        )

        field.placeholderString = "4-digit passcode"

        alert.accessoryView = field

        alert.addButton(withTitle: "Close")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {

            if field.stringValue == savedPasscode {
                return true
            }

            let error = NSAlert()

            error.messageText =
                "Incorrect Passcode ❌"

            error.informativeText =
                "You need the correct passcode to close the app."

            error.addButton(withTitle: "OK")

            error.runModal()
        }

        return false
    }
}

/// Installs the close guard after SwiftUI has attached this view to its window.
struct WindowCloseGuard: NSViewRepresentable {
    func makeCoordinator() -> WindowDelegate {
        WindowDelegate()
    }

    func makeNSView(context: Context) -> NSView {
        NSView()
    }

    func updateNSView(_ view: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            if !(window.delegate is WindowDelegate) {
                window.delegate = context.coordinator
            }
        }
    }
}
