import Foundation
import GRDB
import SwiftUI

enum EntryType: String, Codable {
    case place
    case person
}

enum DayPeriod: String, CaseIterable {
    case earlyMorning = "early-morning"
    case lateMorning = "late-morning"
    case earlyAfternoon = "early-afternoon"
    case lateAfternoon = "late-afternoon"
    case earlyEvening = "early-evening"
    case evening
    case night
}

struct Entry: Codable, Equatable, Identifiable, FetchableRecord, PersistableRecord {
    let id: Int64
    var type: EntryType
    var name: String
    var city: String
    var country: String
    var timezoneIdentifier: String
    var flag: String?
    var photoData: String?

    enum Columns: String, ColumnExpression {
        case id, type, name, city, country, timezoneIdentifier, flag, photoData
    }

    init(id: Int64 = Int64.random(in: 1 ... 99999), type: EntryType, name: String, city: String, country: String, timezoneIdentifier: String, flag: String? = nil, photoData: String? = nil) {
        self.id = id
        self.type = type
        self.name = name
        self.city = city
        self.country = country
        self.timezoneIdentifier = timezoneIdentifier
        self.flag = flag
        self.photoData = photoData
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, type, name, city, country, timezoneIdentifier, flag, photoData
    }

    var timeDifference: (hours: Int, minutes: Int, dayPeriod: DayPeriod) {
        let currentDate = Date()
        let calendar = Calendar.current

        // Get the current user's time zone
        let localTimeZone = TimeZone.current

        // Get the entry's time zone
        guard let entryTimeZone = TimeZone(identifier: timezoneIdentifier) else {
            return (0, 0, .night)
        }

        // Calculate the time difference
        let differenceInSeconds = entryTimeZone.secondsFromGMT(for: currentDate) - localTimeZone.secondsFromGMT(for: currentDate)

        // Convert seconds to hours and minutes
        let hours = differenceInSeconds / 3600
        let minutes = (differenceInSeconds % 3600) / 60

        // Calculate the time in the entry's time zone
        var entryDateComponents = calendar.dateComponents(in: entryTimeZone, from: currentDate)
        let entryHour = entryDateComponents.hour ?? 0

        let dayPeriod: DayPeriod
        switch entryHour {
        case 5 ..< 8:
            dayPeriod = .earlyMorning
        case 8 ..< 12:
            dayPeriod = .lateMorning
        case 12 ..< 15:
            dayPeriod = .earlyAfternoon
        case 15 ..< 17:
            dayPeriod = .lateAfternoon
        case 17 ..< 19:
            dayPeriod = .earlyEvening
        case 19 ..< 22:
            dayPeriod = .evening
        default:
            dayPeriod = .night
        }

        return (hours, minutes, dayPeriod)
    }

    var timeIcon: String {
        return timeDifference.dayPeriod.rawValue
    }
}
