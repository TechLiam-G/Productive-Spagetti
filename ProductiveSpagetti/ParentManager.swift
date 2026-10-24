import Foundation
import AppKit

@MainActor
final class ParentManager {

    static let shared = ParentManager()

    private init() {}

    private var passcode: String {
        UserDefaults.standard.string(forKey: "lockpasscode") ?? ""
    }

    func authenticate(
        title: String = "Parent Passcode",
        message: String = "Enter the 4-digit parent passcode."
    ) -> Bool {

        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message

        let field = NSSecureTextField(
            frame: NSRect(x: 0, y: 0, width: 220, height: 24)
        )
        field.placeholderString = "4 digits"

        alert.accessoryView = field

        alert.addButton(withTitle: "Continue")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()

        guard response == .alertFirstButtonReturn else {
            return false
        }

        return field.stringValue == passcode
    }
}
