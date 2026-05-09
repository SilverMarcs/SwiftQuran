import Foundation
import SQLite

@Observable
final class QuranDataManager {
    @ObservationIgnored private let database: Connection

    private(set) var surahs: [Surah]

    init(bundle: Bundle = .main) {
        guard let databaseURL = bundle.url(forResource: "quran", withExtension: "sqlite") else {
            fatalError("quran.sqlite not found in bundle")
        }

        do {
            database = try Connection(databaseURL.path, readonly: true)
            surahs = []
            surahs = loadSurahs()
        } catch {
            fatalError("Failed to open quran.sqlite: \(error)")
        }
    }

    func surah(id: Int) -> Surah? {
        surahs.first { $0.id == id }
    }

    func loadVerses(for surah: Surah) -> [Verse] {
        let sql = """
            SELECT a.ayatID, a.ayatText, e.ayatText, ia.surahAyatID, ia.Prostation
            FROM ArabicAmiri a
            JOIN English e ON e.ayatID = a.ayatID
            JOIN IndexAyat ia ON ia.ayatID = a.ayatID
            WHERE CAST(a.ayatID AS INTEGER) >= ? AND CAST(a.ayatID AS INTEGER) <= ?
            ORDER BY CAST(a.ayatID AS INTEGER)
            """

        do {
            let statement = try database.prepare(sql, surah.ayatFrom, surah.ayatTo)
            return statement.compactMap { row -> Verse? in
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
                    verseIndex: surahAyatID,
                    isProstrationVerse: (intValue(row[4]) ?? 0) > 0
                )
            }
        } catch {
            print("Error loading verses for surah \(surah.id): \(error)")
            return []
        }
    }

    func savedVerses(for verseKeys: Set<String>) -> [Verse] {
        var verseNumbersBySurah: [Int: [Int]] = [:]

        for verseKey in verseKeys {
            let components = verseKey.split(separator: "_")
            guard components.count == 2,
                  let surahID = Int(components[0]),
                  let verseNumber = Int(components[1]) else {
                continue
            }

            verseNumbersBySurah[surahID, default: []].append(verseNumber)
        }

        var result: [Verse] = []

        for (surahID, verseNumbers) in verseNumbersBySurah {
            guard let surah = surah(id: surahID) else {
                continue
            }

            let verses = loadVerses(for: surah).filter { verse in
                verseNumbers.contains(verse.verseIndex)
            }
            result.append(contentsOf: verses)
        }

        return result.sorted { lhs, rhs in
            if lhs.surahNumber == rhs.surahNumber {
                return lhs.verseIndex < rhs.verseIndex
            }

            return lhs.surahNumber < rhs.surahNumber
        }
    }

    func tafseer(for verse: Verse) -> String? {
        text(
            in: "Tafseer",
            textColumn: "ayatText",
            idColumn: "ayatID",
            verseID: verse.id
        )
    }

    func commentary(for verse: Verse) -> String? {
        text(
            in: "Commentary",
            textColumn: "ayatText",
            idColumn: "ayatID",
            verseID: verse.id
        )
    }

    func hadiths(for verse: Verse) -> [VerseHadith] {
        let sql = """
            SELECT h.hadithID, h.hadithNum, h.hadithTxt
            FROM IndexHadith ih
            JOIN Hadith h ON h.hadithID = ih.hadithID
            WHERE CAST(ih.ayatNum AS INTEGER) = ?
            ORDER BY CAST(ih.hadithNum AS INTEGER), CAST(h.hadithID AS INTEGER)
            """

        do {
            let statement = try database.prepare(sql, verse.id)
            return statement.compactMap { row -> VerseHadith? in
                guard let id = intValue(row[0]),
                      let number = intValue(row[1]),
                      let text = trimmedStringValue(row[2]) else {
                    return nil
                }

                return VerseHadith(id: id, number: number, text: text)
            }
        } catch {
            print("Error loading hadith for verse \(verse.id): \(error)")
            return []
        }
    }

    private func loadSurahs() -> [Surah] {
        let sql = """
            SELECT surahID, surahNameArabic, surahNameEnglish, surahTranslation, surahAyatFrom, surahAyatTo, MakkiMadni
            FROM IndexSurah ORDER BY CAST(surahID AS INTEGER)
            """

        do {
            let statement = try database.prepare(sql)
            return statement.compactMap { row -> Surah? in
                guard let id = intValue(row[0]),
                      let nameArabic = stringValue(row[1]),
                      let nameEnglish = stringValue(row[2]),
                      let ayatFrom = intValue(row[4]),
                      let ayatTo = intValue(row[5]),
                      let makkiMadni = intValue(row[6]) else {
                    return nil
                }

                return Surah(
                    id: id,
                    name: nameArabic,
                    transliteration: nameEnglish,
                    translation: stringValue(row[3]) ?? "",
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

    private func text(
        in table: String,
        textColumn: String,
        idColumn: String,
        verseID: Int
    ) -> String? {
        let sql = """
            SELECT \(textColumn)
            FROM \(table)
            WHERE CAST(\(idColumn) AS INTEGER) = ?
            LIMIT 1
            """

        do {
            let statement = try database.prepare(sql, verseID)
            for row in statement {
                return trimmedStringValue(row[0])
            }
        } catch {
            print("Error loading \(table) for verse \(verseID): \(error)")
        }

        return nil
    }

    private func intValue(_ binding: Binding?) -> Int? {
        switch binding {
        case let integer as Int64:
            Int(integer)
        case let string as String:
            Int(string)
        default:
            nil
        }
    }

    private func stringValue(_ binding: Binding?) -> String? {
        binding as? String
    }

    private func trimmedStringValue(_ binding: Binding?) -> String? {
        guard let text = stringValue(binding)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty else {
            return nil
        }

        return text
    }
}
