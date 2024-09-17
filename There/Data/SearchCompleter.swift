import Foundation
import MapKit

class TimeZoneSearchCompiler: NSObject, MKLocalSearchCompleterDelegate {
    private let searchCompleter: MKLocalSearchCompleter
    private var commonAbbreviations: [String: (fullName: String, identifier: String)]
    private var utcOffsets: [String: String]
    private var currentCompletion: (([TimeZoneSearchResult]) -> Void)?

    override init() {
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter.resultTypes = .address

        // Initialize common abbreviations
        commonAbbreviations = [
            // North America
            "EST": ("Eastern Standard Time", "America/New_York"),
            "EDT": ("Eastern Daylight Time", "America/New_York"),
            "CST": ("Central Standard Time", "America/Chicago"),
            "CDT": ("Central Daylight Time", "America/Chicago"),
            "MST": ("Mountain Standard Time", "America/Denver"),
            "MDT": ("Mountain Daylight Time", "America/Denver"),
            "PST": ("Pacific Standard Time", "America/Los_Angeles"),
            "PDT": ("Pacific Daylight Time", "America/Los_Angeles"),
            "AKST": ("Alaska Standard Time", "America/Anchorage"),
            "AKDT": ("Alaska Daylight Time", "America/Anchorage"),
            "HST": ("Hawaii Standard Time", "Pacific/Honolulu"),

            // Europe
            "GMT": ("Greenwich Mean Time", "Etc/GMT"),
            "BST": ("British Summer Time", "Europe/London"),
            "CET": ("Central European Time", "Europe/Paris"),
            "CEST": ("Central European Summer Time", "Europe/Paris"),

            // Asia
            "IST": ("India Standard Time", "Asia/Kolkata"),
            "JST": ("Japan Standard Time", "Asia/Tokyo"),

            // Australia
            "AEST": ("Australian Eastern Standard Time", "Australia/Sydney"),
            "AEDT": ("Australian Eastern Daylight Time", "Australia/Sydney"),

            // Coordinated Universal Time
            "UTC": ("Coordinated Universal Time", "Etc/UTC"),
        ]

        // Initialize UTC offsets
        utcOffsets = [
            "UTC+0": "Etc/GMT",
            "UTC-1": "Etc/GMT+1",
            "UTC-2": "Etc/GMT+2",
            "UTC-3": "Etc/GMT+3",
            "UTC-4": "Etc/GMT+4",
            "UTC-5": "Etc/GMT+5",
            "UTC-6": "Etc/GMT+6",
            "UTC-7": "Etc/GMT+7",
            "UTC-8": "Etc/GMT+8",
            "UTC-9": "Etc/GMT+9",
            "UTC-10": "Etc/GMT+10",
            "UTC-11": "Etc/GMT+11",
            "UTC-12": "Etc/GMT+12",
            "UTC+1": "Etc/GMT-1",
            "UTC+2": "Etc/GMT-2",
            "UTC+3": "Etc/GMT-3",
            "UTC+4": "Etc/GMT-4",
            "UTC+5": "Etc/GMT-5",
            "UTC+5:30": "Asia/Kolkata",
            "UTC+6": "Etc/GMT-6",
            "UTC+7": "Etc/GMT-7",
            "UTC+8": "Etc/GMT-8",
            "UTC+9": "Etc/GMT-9",
            "UTC+10": "Etc/GMT-10",
            "UTC+11": "Etc/GMT-11",
            "UTC+12": "Etc/GMT-12",
            "UTC+13": "Pacific/Apia",
            "UTC+14": "Pacific/Kiritimati",
        ]

        super.init()
        searchCompleter.delegate = self
    }

    func search(query: String, completion: @escaping ([TimeZoneSearchResult]) -> Void) {
        currentCompletion = completion
        searchCompleter.queryFragment = query
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = processResults(completer.results)
        DispatchQueue.main.async { [weak self] in
            self?.currentCompletion?(results)
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            self?.currentCompletion?([])
        }
    }

    private func processResults(_ suggestions: [MKLocalSearchCompletion]) -> [TimeZoneSearchResult] {
        var results: [TimeZoneSearchResult] = []

        // Add abbreviation results first
        results += searchAbbreviations(query: searchCompleter.queryFragment)

        // Add UTC offset results
        results += searchUTCOffsets(query: searchCompleter.queryFragment)

        // Process city results
        for suggestion in suggestions {
            let components = suggestion.title.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            if components.count >= 2 {
                let city = components[0]
                let country = components.last ?? ""
                results.append(TimeZoneSearchResult(title: city, subtitle: country, identifier: nil, type: .city, region: nil))
            }
        }

        return results
    }

    private func searchAbbreviations(query: String) -> [TimeZoneSearchResult] {
        return commonAbbreviations
            .filter { $0.key.lowercased().contains(query.lowercased()) }
            .map { TimeZoneSearchResult(title: $0.key, subtitle: $0.value.fullName, identifier: $0.value.identifier, type: .abbreviation, region: nil) }
    }

    private func searchUTCOffsets(query: String) -> [TimeZoneSearchResult] {
        return utcOffsets
            .filter { $0.key.lowercased().contains(query.lowercased()) }
            .map { TimeZoneSearchResult(title: $0.key, subtitle: "Coordinated Universal Time Offset", identifier: $0.value, type: .utcOffset, region: nil) }
    }
}

struct TimeZoneSearchResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let identifier: String?
    let type: TimeZoneSearchResultType
    let region: CLRegion?

    func getTimeZone() -> TimeZone? {
        switch type {
        case .city:
            if let region = region as? CLCircularRegion {
                let location = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
                return TimeZone.timeZone(for: location)
            }
            return nil
        case .abbreviation, .utcOffset:
            return identifier.flatMap { TimeZone(identifier: $0) }
        }
    }
}

enum TimeZoneSearchResultType {
    case city
    case abbreviation
    case utcOffset
}

extension TimeZone {
    static func timeZone(for location: CLLocation) -> TimeZone? {
        let geocoder = CLGeocoder()
        var timeZone: TimeZone?

        let semaphore = DispatchSemaphore(value: 0)
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            timeZone = placemarks?.first?.timeZone
            semaphore.signal()
        }
        semaphore.wait()

        return timeZone
    }
}

class SearchCompleter: ObservableObject {
    @Published var results: [TimeZoneSearchResult] = []
    @Published var queryFragment: String = "" {
        didSet {
            if queryFragment.isEmpty {
                results = defaultResults
            } else {
                timeZoneSearchCompiler.search(query: queryFragment) { [weak self] searchResults in
                    DispatchQueue.main.async {
                        self?.results = searchResults
                    }
                }
            }
        }
    }

    private let timeZoneSearchCompiler: TimeZoneSearchCompiler
    private var defaultResults: [TimeZoneSearchResult] = []

    init() {
        timeZoneSearchCompiler = TimeZoneSearchCompiler()
        setupDefaultResults()
    }

    private func setupDefaultResults() {
        // All timezones and locations
        for identifier in TimeZone.knownTimeZoneIdentifiers {
            let components = identifier.split(separator: "/")
            if components.count >= 2 {
                let location = String(components.last!).replacingOccurrences(of: "_", with: " ")
                let region = String(components.first!)
                defaultResults.append(TimeZoneSearchResult(title: location, subtitle: region, identifier: identifier, type: .city, region: nil))
            }
        }

        // Add UTC offsets
        for offset in -12 ... 14 {
            let sign = offset >= 0 ? "+" : ""
            let title = "UTC\(sign)\(offset)"
            let identifier = "Etc/GMT\(offset == 0 ? "" : (offset > 0 ? "-" : "+") + "\(abs(offset))")"
            defaultResults.append(TimeZoneSearchResult(title: title, subtitle: "Coordinated Universal Time Offset", identifier: identifier, type: .utcOffset, region: nil))
        }

        results = defaultResults
    }

    private func updateResults(for query: String) {
        if query.isEmpty {
            results = defaultResults
        } else {
            timeZoneSearchCompiler.search(query: query) { [weak self] searchResults in
                DispatchQueue.main.async {
                    self?.results = searchResults
                }
            }
        }
    }
}
