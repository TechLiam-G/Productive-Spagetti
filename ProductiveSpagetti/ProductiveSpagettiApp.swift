import SwiftUI

@main
struct ProductiveSpagettiApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    //init() {
    //  CloudSaveManager.shared.startAutoSave()
    //}

    var body: some Scene {

        WindowGroup {
            ContentView()
        }
    }
}
