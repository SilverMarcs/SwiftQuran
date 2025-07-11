//
//  SettingsToolbar.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 11/07/2025.
//

import SwiftUI

struct SettingsToolbar: ToolbarContent {
    @State private var showSettings: Bool = false
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showSettings.toggle()
            } label: {
                Label("Settings", systemImage: "gear")
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}
