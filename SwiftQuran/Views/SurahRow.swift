//
//  SurahRow.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 14/03/2025.
//

import SwiftUI
import SwiftData

struct SurahRow: View {
    let surah: Surah
    let progress: ReadingProgress?
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(alignment: .center) {
            Text("\(surah.id)")
                .foregroundStyle(.secondary)
                #if !(macOS)
                .padding(.trailing, 2)
                #endif
            
            VStack(alignment: .leading, spacing: 4) {
                Text(surah.transliteration)
                    .font(.headline)
                Text("\(surah.translation) • \(surah.name)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                if let progress = progress {
                    Text("\(progress.lastReadVerseId ?? 0)/\(surah.totalVerses)")
                        .font(.subheadline)
                        .foregroundStyle(.tint)
                } else {
                    Text("\(surah.totalVerses)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if progress != nil {
                Button(role: .destructive) {
                    if let progress = progress {
                        modelContext.delete(progress)
                    }
                } label: {
                    Label("Reset Progress", systemImage: "arrow.counterclockwise")
                }
            }
        }
    }
}
