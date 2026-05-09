//
//  SettingsModifier.swift
//  SwiftQuran
//

import SwiftUI

struct SettingsModifier: ViewModifier {
    @State private var showSettings: Bool = false
    @Namespace private var transition

    func body(content: Content) -> some View {
        #if os(macOS)
        content
        #else
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                .matchedTransitionSource(id: "settings-button", in: transition)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .navigationTransition(.zoom(sourceID: "settings-button", in: transition))
            }
        #endif
    }
}

extension View {
    func settingsSheet() -> some View {
        modifier(SettingsModifier())
    }
}
