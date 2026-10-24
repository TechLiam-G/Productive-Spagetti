import SwiftUI
import UserNotifications
import AppKit

struct ResetView: View {

    @AppStorage("forChild") private var forChild = false
    @AppStorage("lockpasscode") private var lockpasscode = ""

    @AppStorage("score") private var score = 0
    @AppStorage("completedRuns") private var completedRuns = 0
    @AppStorage("totalFocusMinutes") private var totalFocusMinutes = 0
    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("longestStreak") private var longestStreak = 0

    @AppStorage("focusHistoryData") private var focusHistoryData = ""
    @AppStorage("blockedAppsData") private var blockedAppsData = ""
    @AppStorage("blockedAppCountsData") private var blockedAppCountsData = Data()
    @AppStorage("runlog") private var runlog = ""
    @AppStorage("coins") private var coins = 0
    @AppStorage("backgrounds") private var backgrounds = ""
    @AppStorage("equippedBackground") private var equippedBackground = "default"
    @AppStorage("scoreHistory") private var scoreHistoryData = ""

    // Pets
    @AppStorage("pets") private var pets = ""
    @AppStorage("equippedPet") private var equippedPet = ""

    // Achievements
    @AppStorage("achievements") private var achievements = ""

    @State private var showingConfirmation = false
    @State private var showingPasscode = false
    @State private var enteredPasscode = ""
    @State private var passcodeError = ""

    var body: some View {

        ZStack {

            LinearGradient(
                colors: [
                    .red.opacity(0.25),
                    .orange.opacity(0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {

                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.red)

                Text("Reset All Data")
                    .font(.largeTitle.bold())

                Text("""
                This will permanently erase:

                • Productivity score
                • Focus history
                • Blocked apps
                • Streaks
                • Run log
                • Coins
                • Backgrounds
                • Pets
                • Achievements

                This cannot be undone.
                """)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

                Button(role: .destructive) {

                    if forChild {

                        // Parental Controls are ON
                        enteredPasscode = ""
                        passcodeError = ""
                        showingPasscode = true

                    } else {

                        // No parental controls
                        showingConfirmation = true
                    }

                } label: {

                    Label(
                        "Reset Everything",
                        systemImage: "trash.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(40)
        }

        // MARK: - Reset Confirmation

        .alert(
            "Reset Everything?",
            isPresented: $showingConfirmation
        ) {

            Button("Cancel", role: .cancel) {}

            Button(
                "Reset",
                role: .destructive
            ) {

                resetEverything()

            }

        } message: {

            Text("All saved data will be erased.")

        }

        // MARK: - Passcode

        .alert(
            "Parental Controls",
            isPresented: $showingPasscode
        ) {

            SecureField(
                "4-digit passcode",
                text: $enteredPasscode
            )

            Button("Cancel") {

                clearPasscode()

            }

            Button("Unlock") {

                checkPasscode()

            }

        } message: {

            Text(
                passcodeError.isEmpty
                ? "Enter the Parental Controls passcode to reset all data."
                : passcodeError
            )

        }
    }

    // MARK: - Check Passcode

    private func checkPasscode() {

        if enteredPasscode == lockpasscode {

            clearPasscode()

            // Correct passcode → show confirmation
            showingConfirmation = true

        } else {

            passcodeError = "❌ Incorrect passcode."
        }
    }

    // MARK: - Clear Passcode

    private func clearPasscode() {

        enteredPasscode = ""
        passcodeError = ""
    }

    // MARK: - Reset Everything

    private func resetEverything() {

        // Remove EVERY @AppStorage / UserDefaults value
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(
                forName: bundleID
            )
        }

        // Remove scheduled notifications too
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()

        // Reset app to a clean state
        print("✅ All Productive Spagetti data reset")
    }
}

#Preview {
    ResetView()
}

