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
        .listRowInsets(.init(top: 6, leading: 10, bottom: 6, trailing: 10))
        .listRowBackground(
            RoundedRectangle(cornerRadius: 12)
                .fill(type.color.opacity(isCurrent ? 0.65 : 0.35))
        )
    }
}
