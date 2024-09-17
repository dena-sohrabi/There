import Foundation
import MapKit

class TimeZoneSearchCompiler: NSObject {
    private var commonAbbreviations: [String: (fullName: String, identifier: String)]
    private var utcOffsets: [String: String]
    private var currentCompletion: (([TimeZoneSearchResult]) -> Void)?

    override init() {
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
    }

    func search(query: String, completion: @escaping ([TimeZoneSearchResult]) -> Void) {
        currentCompletion = completion

        let results = searchAbbreviations(query: query) + searchUTCOffsets(query: query)

        if !results.isEmpty {
            completion(results)
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address
        

        let search = MKLocalSearch(request: request)
        
        search.start { [weak self] response, _ in
            guard let self = self, let response = response else {
                completion([])
                return
            }

            let results = self.processResults(response.mapItems)
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }

    private func processResults(_ mapItems: [MKMapItem]) -> [TimeZoneSearchResult] {
        return mapItems.compactMap { item in
//            guard let placemark = item.placemark else { return nil }
            let placemark = item.placemark
            

            let city = placemark.locality ?? placemark.name ?? ""
            let country = placemark.country ?? ""
            // placemark.administrativeArea,
            let subtitle = [country].compactMap { $0 }.joined(separator: ", ")

            print("placemark.timeZone \(city) \(placemark)")
            
            return TimeZoneSearchResult(
                title: city,
                subtitle: subtitle,
                identifier: placemark.timeZone?.identifier,
                type: .city,
                region: placemark.region,
                coordinate: placemark.location
            )
        }
    }

    private func searchAbbreviations(query: String) -> [TimeZoneSearchResult] {
        return commonAbbreviations
            .filter { $0.key.lowercased().contains(query.lowercased()) }
            .map { TimeZoneSearchResult(title: $0.key, subtitle: $0.value.fullName, identifier: $0.value.identifier, type: .abbreviation, region: nil, coordinate: nil) }
    }

    private func searchUTCOffsets(query: String) -> [TimeZoneSearchResult] {
        return utcOffsets
            .filter { $0.key.lowercased().contains(query.lowercased()) }
            .map { TimeZoneSearchResult(title: $0.key, subtitle: "Coordinated Universal Time Offset", identifier: $0.value, type: .utcOffset, region: nil, coordinate: nil) }
    }
}

struct TimeZoneSearchResult: Identifiable, Equatable {
    static func ==(lhs: TimeZoneSearchResult, rhs: TimeZoneSearchResult) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.subtitle == rhs.subtitle && lhs.identifier == rhs.identifier && lhs.type == rhs.type && lhs.region == rhs.region
    }
    
    let id = UUID()
    let title: String
    let subtitle: String
    let identifier: String?
    let type: TimeZoneSearchResultType
    let region: CLRegion?
    let coordinate: CLLocation?

    func getTimeZone() async  -> TimeZone? {
        switch type {
        case .city:
            print("title \(title) coordinate \(coordinate) region \(region)")
            if let coordinate = coordinate {
                
                return await TimeZone.timeZone(for: coordinate)
            }
            if let region = region as? CLCircularRegion {
                let location = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
                return await TimeZone.timeZone(for: location)
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
    static func timeZone(for location: CLLocation) async -> TimeZone? {
           let geocoder = CLGeocoder()
           do {
               let placemarks = try await geocoder.reverseGeocodeLocation(location)
               print("\(placemarks)")
               return placemarks.first?.timeZone
           } catch {
               print("Geocoding error: \(error.localizedDescription)")
               return nil
           }
       }
}

class SearchCompleter: ObservableObject {
    @Published var results: [TimeZoneSearchResult] = []
    @Published var queryFragment: String = "" {
        didSet {
            if queryFragment.isEmpty {
                results = defaultResults
            } else {
                updateResults(for: queryFragment)
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
                defaultResults.append(TimeZoneSearchResult(title: location, subtitle: region, identifier: identifier, type: .city, region: nil, coordinate: nil))
            }
        }

        // Add UTC offsets
        for offset in -12 ... 14 {
            let sign = offset >= 0 ? "+" : ""
            let title = "UTC\(sign)\(offset)"
            let identifier = "Etc/GMT\(offset == 0 ? "" : (offset > 0 ? "-" : "+") + "\(abs(offset))")"
            defaultResults.append(TimeZoneSearchResult(title: title, subtitle: "Coordinated Universal Time Offset", identifier: identifier, type: .utcOffset, region: nil, coordinate: nil))
        }

        results = defaultResults
    }

    private var latestSearch = ""

    private func updateResults(for query: String) {
        latestSearch = query

        if query.isEmpty {
            results = defaultResults
        } else {
            timeZoneSearchCompiler.search(query: query) { [weak self] searchResults in
                DispatchQueue.main.async {
                    if self?.latestSearch == query {
                        self?.results = searchResults
                    } else {
                        // discard
                    }
                }
            }
        }
    }
}
