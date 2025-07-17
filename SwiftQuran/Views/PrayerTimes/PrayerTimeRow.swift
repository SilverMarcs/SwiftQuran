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
    
    var formattedTime: String {
        let cleaned = time.replacingOccurrences(of: "%", with: "")
        let components = cleaned.split(separator: " ")
        guard components.count == 2 else { return cleaned }
        let hour = components[0]
        let ampm = components[1].uppercased()
        return "\(hour) \(ampm)"
    }
    
    var body: some View {
        HStack {
            Label {
                Text(type.label)
            } icon: {
                Image(systemName: type.symbol)
            }
            
            Spacer()
            
            Text(formattedTime)
                .contentTransition(.numericText())
                .bold()
//                .foregroundStyle(.secondary)
        }
    }
}
