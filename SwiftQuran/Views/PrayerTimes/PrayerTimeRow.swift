//
//  PrayerTimeRow.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 17/07/2025.
//

import SwiftUI

struct PrayerTimeRow: View {
    let title: String
    let time: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(time)
        }
    }
}
