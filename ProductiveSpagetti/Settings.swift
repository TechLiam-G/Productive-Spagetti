//
//  Settings.swift
//  ProductiveSpagetti
//
//  Created by Liam Gao on 8/7/26.
//

import Foundation
import SwiftUI
import AppKit
import AuthenticationServices

struct Settings: View {
    @AppStorage("forChild") private var forChild = false
    @AppStorage("lockpasscode") private var lockpasscode = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("lock_mode") private var lock_mode = false
    @AppStorage("blocker") private var blocker = false
    @AppStorage("autoBlockOnRun") private var autoBlockOnRun = false

    @StateObject private var premium = PremiumManager.shared

    @State private var showingPasscodePrompt = false
    @State private var showingChangePasscode = false

    @State private var enteredPasscode = ""
    @State private var newPasscode = ""
    @State private var confirmPasscode = ""
    @State private var passcodeError = ""

    @State private var showLockModeHelp = false
    @State private var showBlockerHelp = false

    var body: some View {
        Form {
            Section("Parental Controls") {
                Toggle(
                    "Parental Controls",
                    isOn: Binding(
                        get: {
                            forChild
                        },
                        set: { newValue in
                            if newValue {
                                if lockpasscode.isEmpty {
                                    addPasscode()
                                } else {
                                    forChild = true
                                }
                            } else {
                                enteredPasscode = ""
                                passcodeError = ""
                                showingPasscodePrompt = true
                            }
                        }
                    )
                )

                if forChild {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)

                        Text("Parental Controls are on")

                        Spacer()
                    }

                    Button {
                        enteredPasscode = ""
                        newPasscode = ""
                        confirmPasscode = ""
                        passcodeError = ""
                        showingChangePasscode = true
                    } label: {
                        Label("Change Passcode", systemImage: "lock.rotation")
                    }
                }
            }

            if premium.isPremium {
                Section("Premium") {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)

                        Text("Premium")
                            .font(.headline)

                        Spacer()

                        Text("Active")
                            .foregroundStyle(.green)
                    }

                    HStack {
                        Label("Lock Mode", systemImage: "lock.fill")

                        Spacer()

                        Button {
                            showLockModeHelp.toggle()
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $showLockModeHelp) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Lock Mode")
                                    .font(.headline)

                                Text("Lock Mode prevents you from pausing or stopping a productive run.")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(width: 280)
                        }

                        Toggle(
                            "",
                            isOn: Binding(
                                get: {
                                    lock_mode
                                },
                                set: { newValue in
                                    if !forChild {
                                        lock_mode = newValue
                                        return
                                    }

                                    if ParentManager.shared.authenticate(
                                        title: newValue ? "Enable Lock Mode" : "Disable Lock Mode",
                                        message: "Enter the parent passcode to change Lock Mode."
                                    ) {
                                        lock_mode = newValue
                                    }
                                }
                            )
                        )
                        .labelsHidden()
                    }

                    HStack {
                        Label("Blocker Mode", systemImage: "nosign")

                        Spacer()

                        Button {
                            showBlockerHelp.toggle()
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $showBlockerHelp) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Blocker Mode")
                                    .font(.headline)

                                Text("Blocker Mode closes blocked apps during a productive run.")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(width: 280)
                        }

                        Toggle(
                            "",
                            isOn: Binding(
                                get: {
                                    blocker
                                },
                                set: { newValue in
                                    if !forChild {
                                        blocker = newValue
                                        return
                                    }

                                    if ParentManager.shared.authenticate(
                                        title: newValue ? "Enable Blocker Mode" : "Disable Blocker Mode",
                                        message: "Enter the parent passcode to change Blocker Mode."
                                    ) {
                                        blocker = newValue
                                    }
                                }
                            )
                        )
                        .labelsHidden()
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Automatically Enable Blocking")
                                .font(.body)

                            Text("Turn on app blocking when a focus session starts.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Toggle(
                            "",
                            isOn: Binding(
                                get: { autoBlockOnRun },
                                set: { newValue in
                                    if !forChild {
                                        autoBlockOnRun = newValue
                                        return
                                    }

                                    if ParentManager.shared.authenticate(
                                        title: newValue
                                            ? "Enable Automatic Blocking"
                                            : "Disable Automatic Blocking",
                                        message: "Enter the parent passcode to change this setting."
                                    ) {
                                        autoBlockOnRun = newValue
                                    }
                                }
                            )
                        )
                        .labelsHidden()
                        .toggleStyle(.switch)
                    }
                    .padding(.vertical, 6)
                }
            }

            Section("Notifications") {
                Toggle("Notifications", isOn: $notificationsEnabled)

                Button {
                    Task {
                        await NotificationManager.shared.requestPermission()
                    }
                } label: {
                    Label("Allow Notifications", systemImage: "bell")
                }
            }

            Section("App") {
//                NavigationLink {
//                    WebsiteBlockerView()
//                } label: {
//                    Label("Website Blocker", systemImage: "globe")
//                }

                NavigationLink {
                    ResetView()
                } label: {
                    Label("Reset App Data", systemImage: "trash")
                }
                .foregroundStyle(.red)
            }

            Section {
                HStack {
                    Text("Productive Spagetti")

                    Spacer()

                    Text("v1.4")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 600)
        .alert(
            "Enter Passcode",
            isPresented: $showingPasscodePrompt
        ) {
            SecureField(
                "4-digit passcode",
                text: $enteredPasscode
            )

            Button("Cancel") {
                clearPasscodeFields()
            }

            Button("Unlock") {
                checkPasscode()
            }
        } message: {
            Text(
                passcodeError.isEmpty
                ? "Enter your 4-digit passcode to turn off Parental Controls."
                : passcodeError
            )
        }
        .alert(
            "Change Passcode",
            isPresented: $showingChangePasscode
        ) {
            SecureField(
                "Current passcode",
                text: $enteredPasscode
            )

            SecureField(
                "New 4-digit passcode",
                text: $newPasscode
            )

            SecureField(
                "Confirm new passcode",
                text: $confirmPasscode
            )

            Button("Cancel") {
                clearPasscodeFields()
            }

            Button("Change") {
                changePasscode()
            }
        } message: {
            Text(
                passcodeError.isEmpty
                ? "Enter your current passcode and choose a new 4-digit passcode."
                : passcodeError
            )
        }
        .navigationTitle("Settings")
    }

    private func addPasscode() {
        let alert = NSAlert()
        alert.messageText = "Create a Passcode"
        alert.informativeText = "Create a 4-digit passcode for Parental Controls."

        let field = NSSecureTextField(
            frame: NSRect(
                x: 0,
                y: 0,
                width: 220,
                height: 24
            )
        )

        field.placeholderString = "4 digits"
        alert.accessoryView = field
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            let passcode = field.stringValue

            if passcode.count == 4 && passcode.allSatisfy({ $0.isNumber }) {
                lockpasscode = passcode
                forChild = true
            } else {
                let error = NSAlert()
                error.messageText = "Invalid Passcode"
                error.informativeText = "Your passcode must contain exactly 4 numbers."
                error.addButton(withTitle: "Try Again")
                error.runModal()
                addPasscode()
            }
        }
    }

    private func checkPasscode() {
        if enteredPasscode == lockpasscode {
            forChild = false
            clearPasscodeFields()
        } else {
            passcodeError = "Incorrect passcode."
        }
    }

    private func changePasscode() {
        guard enteredPasscode == lockpasscode else {
            passcodeError = "Current passcode is incorrect."
            return
        }

        guard newPasscode.count == 4,
              newPasscode.allSatisfy({ $0.isNumber }) else {
            passcodeError = "Your new passcode must be exactly 4 digits."
            return
        }

        guard newPasscode == confirmPasscode else {
            passcodeError = "The new passcodes do not match."
            return
        }

        lockpasscode = newPasscode
        clearPasscodeFields()
    }

    private func clearPasscodeFields() {
        enteredPasscode = ""
        newPasscode = ""
        confirmPasscode = ""
        passcodeError = ""
    }
}

#Preview {
    Settings()
}
