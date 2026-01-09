//
//  PrayerTimeListRow.swift
//  SwiftQuran Watch App
//
//  Created by Zabir Raihan on 09/01/2026.
//

import SwiftUI

struct PrayerTimeListRow: View {
    let type: PrayerTimeType
    let time: String
    let isCurrent: Bool

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
        }
        .listRowBackground(type.color.opacity(isCurrent ? 0.45 : 0.2))
    }
}
