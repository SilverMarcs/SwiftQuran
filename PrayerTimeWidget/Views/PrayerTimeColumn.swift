//
//  PrayerTimeColumn.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import SwiftUI

struct PrayerTimeColumn: View {
    let type: PrayerTimeType
    let time: String
    let isCurrent: Bool
    
    private var timeComponents: (hour: String, ampm: String) {
        let components = time.split(separator: " ")
        guard components.count == 2 else { return (time, "") }
        return (String(components[0]), String(components[1]))
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(type.label)
                .font(.footnote)
                .foregroundStyle(isCurrent ? .accent : .secondary)
            
            Image(systemName: type.symbol)
                .foregroundStyle(isCurrent ? .accent : type.color)
                .font(.subheadline)
            
            Text(timeComponents.hour)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(isCurrent ? .accent : .primary)
                .contentTransition(.numericText())
            
            Text(timeComponents.ampm)
                .font(.caption2)
                .foregroundStyle(isCurrent ? .accent : .secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
