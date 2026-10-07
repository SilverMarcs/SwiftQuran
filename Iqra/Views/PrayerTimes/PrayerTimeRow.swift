//
//  PrayerTimeRow.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 17/07/2025.
//

import SwiftUI

struct PrayerTimeRow: View {
    let type: PrayerTimeType
    let time: String
    let notificationsEnabled: Bool
    let isUpdatingNotifications: Bool
    let toggleNotification: () -> Void
    
    var body: some View {
        HStack {
            Label {
                Text(type.label)
            } icon: {
                Image(systemName: type.symbol)
                    .foregroundStyle(type.color)
            }
            
            Spacer()
            
            Text(time)
                .contentTransition(.numericText())
                .bold()

            Button(action: toggleNotification) {
                Label(
                    notificationsEnabled ? "Disable \(type.label) reminder" : "Enable \(type.label) reminder",
                    systemImage: notificationsEnabled ? "bell.fill" : "bell"
                )
                .labelStyle(.iconOnly)
                #if !os(macOS)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(.rect)
                #endif
            }
            .buttonStyle(.borderless)
            .foregroundStyle(notificationsEnabled ? Color.accentColor : Color.secondary)
            .accessibilityValue(notificationsEnabled ? "On" : "Off")
            .help(notificationsEnabled ? "Disable \(type.label) reminder" : "Enable \(type.label) reminder")
            .disabled(isUpdatingNotifications)
        }
    }
}
