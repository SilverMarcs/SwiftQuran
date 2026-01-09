//
//  NextPrayerShortcuts.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 09/01/2026.
//

import AppIntents

struct NextPrayerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NextPrayerIntent(),
            phrases: [
                "Next prayer in \(.applicationName)",
                "When is the next prayer in \(.applicationName)"
            ],
            shortTitle: "Next Prayer",
            systemImageName: "clock"
        )
    }
}
