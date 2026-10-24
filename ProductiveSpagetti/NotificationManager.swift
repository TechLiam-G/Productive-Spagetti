import Foundation
import UserNotifications
import Combine

@MainActor
final class NotificationManager: ObservableObject {

    static let shared = NotificationManager()
    

    private init() {}

    // MARK: - Request Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(
                    options: [.alert, .sound, .badge]
                )

            print(
                granted
                ? "Notifications allowed"
                : "Notifications denied"
            )

            return granted

        } catch {
            print("Notification permission error:", error)
            return false
        }
    }

    // MARK: - Send Immediately

    func sendReminder(
        title: String = "Time to focus!",
        body: String = "Ready for a productive run?",
        identifier: String = "immediateReminder"
    ) {

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in

            if let error {
                print("❌ Failed to send reminder:", error)
            } else {
                print("✅ Reminder sent")
            }
        }
    }

    // MARK: - Schedule Daily Reminder

    func scheduleFocusReminder(
        hour: Int,
        minute: Int
    ) {

        // Remove old reminder first
        cancelFocusReminder()

        let content = UNMutableNotificationContent()

        content.title = "Time to focus!"
        content.body = "Ready for a productive run?"
        content.sound = .default

        var date = DateComponents()
        date.hour = hour
        date.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: date,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "dailyFocusReminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in

            if let error {
                print("❌ Failed to schedule reminder:", error)
            } else {
                print("✅ Focus reminder scheduled")
            }
        }
    }

    // MARK: - Schedule One-Time Reminder

    func scheduleReminder(
        after seconds: TimeInterval,
        title: String = "Time to focus!",
        body: String = "Ready for a productive run?",
        identifier: String = "scheduledReminder"
    ) {

        cancelReminder(identifier)

        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, seconds),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in

            if let error {
                print("❌ Failed to schedule reminder:", error)
            } else {
                print("✅ One-time reminder scheduled")
            }
        }
    }

    // MARK: - Cancel Daily Focus Reminder

    func cancelFocusReminder() {

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: ["dailyFocusReminder"]
            )

        print("🗑️ Focus reminder cancelled")
    }

    // MARK: - Cancel Any Reminder

    func cancelReminder(_ identifier: String) {

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [identifier]
            )

        print("🗑️ Reminder cancelled:", identifier)
    }

    // MARK: - Cancel Everything

    func cancelAllReminders() {

        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()

        print("🗑️ All reminders cancelled")
    }

    // MARK: - Debug: Show Pending Notifications

    func printPendingReminders() {

        UNUserNotificationCenter.current()
            .getPendingNotificationRequests { requests in

                print("📋 Pending reminders:")

                for request in requests {
                    print("• \(request.identifier)")
                }

                if requests.isEmpty {
                    print("None")
                }
            }
    }
}
