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
    
    private var timeComponents: (hour: String, ampm: String) {
        let components = time.split(separator: " ")
        guard components.count == 2 else { return (time, "") }
        return (String(components[0]), String(components[1]))
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(type.label)
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            Image(systemName: type.symbol)
                .foregroundStyle(type.color)
                .font(.subheadline)
            
            Text(timeComponents.hour)
                .font(.callout)
                .fontWeight(.medium)
                .contentTransition(.numericText())
            
            Text(timeComponents.ampm)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
