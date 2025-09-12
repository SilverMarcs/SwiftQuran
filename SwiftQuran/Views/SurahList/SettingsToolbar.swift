//
//  SettingsToolbar.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct SettingsToolbar: ToolbarContent {
    @Binding var showSettings: Bool
    var transition: Namespace.ID
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showSettings.toggle()
            } label: {
                Label("Settings", systemImage: "gear")
            }
        }
        .matchedTransitionSource(id: "settings-button", in: transition)
    }
}
