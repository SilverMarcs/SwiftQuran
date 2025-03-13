import Foundation
import SwiftData

@Model
final class ReadingProgress {
    var lastReadAt: Date
    var lastReadVerseId: Int
    var surah: Surah?
    
    init(lastReadVerseId: Int, surah: Surah) {
        self.lastReadAt = Date()
        self.lastReadVerseId = lastReadVerseId
        self.surah = surah
    }
}
