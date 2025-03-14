import Foundation
import SwiftData

@Model
final class ReadingProgress {
    var lastReadAt: Date?
    var lastReadVerseId: Int?
    var surahId: Int?
    
    init(lastReadVerseId: Int, surahId: Int) {
        self.lastReadAt = Date()
        self.lastReadVerseId = lastReadVerseId
        self.surahId = surahId
    }
}
