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
    }
}
