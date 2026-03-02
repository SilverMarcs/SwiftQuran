import Foundation
import SQLite

final class QuranDatabase: Sendable {
    static let shared = QuranDatabase()

    private let db: Connection

    private init() {
        guard let path = Bundle.main.path(forResource: "quran", ofType: "sqlite") else {
            fatalError("quran.sqlite not found in bundle")
        }
        do {
            db = try Connection(path, readonly: true)
        } catch {
            fatalError("Failed to open quran.sqlite: \(error)")
        }
    }

    // MARK: - Helpers

    private func intValue(_ binding: Binding?) -> Int? {
        switch binding {
        case let i as Int64: return Int(i)
        case let s as String: return Int(s)
        default: return nil
        }
    }

    private func stringValue(_ binding: Binding?) -> String? {
        binding as? String
    }

    // MARK: - Load Surahs

    func loadSurahs() -> [Surah] {
        let sql = """
            SELECT surahID, surahNameArabic, surahNameEnglish, surahTranslation, surahAyatFrom, surahAyatTo, MakkiMadni
            FROM IndexSurah ORDER BY CAST(surahID AS INTEGER)
            """

        do {
            let stmt = try db.prepare(sql)
            return stmt.compactMap { row in
                guard let id = intValue(row[0]),
                      let nameArabic = stringValue(row[1]),
                      let nameEnglish = stringValue(row[2]),
                      let ayatFrom = intValue(row[4]),
                      let ayatTo = intValue(row[5]),
                      let makkiMadni = intValue(row[6]) else {
                    return nil
                }
                let translation = stringValue(row[3]) ?? ""

                return Surah(
                    id: id,
                    name: nameArabic,
                    transliteration: nameEnglish,
                    translation: translation,
                    type: makkiMadni == 0 ? "meccan" : "medinan",
                    ayatFrom: ayatFrom,
                    ayatTo: ayatTo
                )
            }
        } catch {
            print("Error loading surahs: \(error)")
            return []
        }
    }

    // MARK: - Load Verses

    func loadVerses(for surah: Surah) -> [Verse] {
        let sql = """
            SELECT a.ayatID, a.ayatText, e.ayatText, ia.surahAyatID
            FROM ArabicAmiri a
            JOIN English e ON e.ayatID = a.ayatID
            JOIN IndexAyat ia ON ia.ayatID = a.ayatID
            WHERE CAST(a.ayatID AS INTEGER) >= ? AND CAST(a.ayatID AS INTEGER) <= ?
            ORDER BY CAST(a.ayatID AS INTEGER)
            """

        do {
            let stmt = try db.prepare(sql, surah.ayatFrom, surah.ayatTo)
            return stmt.compactMap { row in
                guard let ayatID = intValue(row[0]),
                      let arabicText = stringValue(row[1]),
                      let englishText = stringValue(row[2]),
                      let surahAyatID = intValue(row[3]) else {
                    return nil
                }

                return Verse(
                    id: ayatID,
                    text: arabicText.trimmingCharacters(in: .whitespaces),
                    translation: englishText.trimmingCharacters(in: .whitespaces),
                    surahNumber: surah.id,
                    verseIndex: surahAyatID
                )
            }
        } catch {
            print("Error loading verses for surah \(surah.id): \(error)")
            return []
        }
    }
}
