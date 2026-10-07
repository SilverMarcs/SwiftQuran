import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
final class PrayerNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = PrayerNotificationManager()

    private var enabledPrayers = Set(UserDefaults.standard.stringArray(forKey: "enabled_prayer_notifications") ?? [])
    private let center = UNUserNotificationCenter.current()
    private(set) var isUpdating = false
    var errorMessage: String?

    private override init() {
        super.init()
        center.delegate = self
    }

    func isEnabled(_ type: PrayerTimeType) -> Bool {
        enabledPrayers.contains(type.rawValue)
    }

    func toggle(_ type: PrayerTimeType, times: PrayerTimes) async {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }

        if isEnabled(type) {
            center.removePendingNotificationRequests(withIdentifiers: [identifier(for: type)])
            center.removeDeliveredNotifications(withIdentifiers: [identifier(for: type)])
            enabledPrayers.remove(type.rawValue)
        } else {
            do {
                guard try await center.requestAuthorization(options: [.alert, .sound]) else {
                    errorMessage = "Allow notifications for Iqra in Settings to enable prayer reminders."
                    return
                }
                guard let request = request(for: type, time: times.time(for: type)) else {
                    errorMessage = "Refresh prayer times and try again."
                    return
                }
                try await center.add(request)
                enabledPrayers.insert(type.rawValue)
            } catch {
                errorMessage = "The prayer reminder couldn't be scheduled. Please try again."
                return
            }
        }
        UserDefaults.standard.set(enabledPrayers.sorted(), forKey: "enabled_prayer_notifications")
    }

    func refresh(times: PrayerTimes?) async {
        guard let times, !enabledPrayers.isEmpty, !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        let status = await center.notificationSettings().authorizationStatus
        guard status == .authorized || status == .provisional else { return }

        do {
            for type in PrayerTimeType.allCases where isEnabled(type) {
                if let request = request(for: type, time: times.time(for: type)) {
                    try await center.add(request)
                }
            }
        } catch {
            errorMessage = "The prayer reminders couldn't be updated. Please try again."
        }
    }

    private func identifier(for type: PrayerTimeType) -> String {
        "prayer-reminder.\(type.rawValue)"
    }

    private func request(for type: PrayerTimeType, time: String) -> UNNotificationRequest? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let cleaned = time.trimmingCharacters(in: .whitespacesAndNewlines)
        formatter.dateFormat = "h:mm a"
        var date = formatter.date(from: cleaned)
        if date == nil {
            formatter.dateFormat = "HH:mm"
            date = formatter.date(from: cleaned)
        }
        guard let date else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = formatter.timeZone
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let content = UNMutableNotificationContent()
        content.title = "\(type.label) time"
        content.body = "It's time for \(type.label)."
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        return UNNotificationRequest(identifier: identifier(for: type), content: content, trigger: trigger)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
