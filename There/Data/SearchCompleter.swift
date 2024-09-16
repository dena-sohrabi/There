import MapKit
import SwiftUI

class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [SearchResult] = []
    @Published var queryFragment: String = "" {
        didSet {
            if queryFragment.isEmpty {
                results = defaultResults
            } else {
                filterResults(for: queryFragment)
            }
        }
    }

    private let completer: MKLocalSearchCompleter
    private var defaultResults: [SearchResult] = []

    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
        setupDefaultResults()
    }

    private func setupDefaultResults() {
        // UTC common offsets
        let commonOffsets = [-12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        for offset in commonOffsets {
            let sign = offset >= 0 ? "+" : ""
            defaultResults.append(SearchResult(title: "UTC\(sign)\(offset)", subtitle: ""))
        }

        // All timezones, locations, and their abbreviations
        for identifier in TimeZone.knownTimeZoneIdentifiers {
            if let timeZone = TimeZone(identifier: identifier) {
                let components = identifier.split(separator: "/")
                if components.count >= 2 {
                    let location = String(components.last!).replacingOccurrences(of: "_", with: " ")
                    let region = String(components.first!)
                    defaultResults.append(SearchResult(title: location, subtitle: region))
                }

                // Add abbreviations
                if let abbreviation = timeZone.abbreviation() {
                    defaultResults.append(SearchResult(title: abbreviation, subtitle: identifier))
                }
            }
        }

        let cityAbbreviations = [
            ("SF", "San Francisco, CA"),
            ("LA", "Los Angeles, CA"),
            ("NYC", "New York City, NY"),
            ("DC", "Washington, D.C."),
            ("CHI", "Chicago, IL"),
            ("LDN", "London, UK"),
            ("TYO", "Tokyo, Japan"),
            ("SYD", "Sydney, Australia"),
        ]

        for (abbr, fullName) in cityAbbreviations {
            defaultResults.append(SearchResult(title: abbr, subtitle: fullName))
            defaultResults.append(SearchResult(title: fullName, subtitle: abbr))
        }

        defaultResults.append(SearchResult(title: "SF, CA", subtitle: "United States"))

        // Add common time zone abbreviations
        let commonAbbreviations = [
            ("PST", "Pacific Standard Time"),
            ("PDT", "Pacific Daylight Time"),
            ("EST", "Eastern Standard Time"),
            ("EDT", "Eastern Daylight Time"),
            ("GMT", "Greenwich Mean Time"),
            ("BST", "British Summer Time"),
            ("IST", "India Standard Time"),
        ]

        for (abbr, fullName) in commonAbbreviations {
            defaultResults.append(SearchResult(title: abbr, subtitle: fullName))
        }

        defaultResults = Array(Set(defaultResults))

        results = defaultResults
    }

    private func filterResults(for query: String) {
        let lowercasedQuery = query.lowercased()
        results = defaultResults.filter { result in
            let titleMatch = result.title.lowercased().contains(lowercasedQuery)
            let subtitleMatch = result.subtitle.lowercased().contains(lowercasedQuery)
            let abbrMatch = result.title.lowercased().components(separatedBy: .whitespaces).contains { $0.starts(with: lowercasedQuery) }
            return titleMatch || subtitleMatch || abbrMatch
        }

        // If no results found in default results, use MKLocalSearchCompleter
        if results.isEmpty {
            completer.queryFragment = query
        }
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let newResults = completer.results.map { SearchResult(title: $0.title, subtitle: $0.subtitle) }
        results = Array(Set(results + newResults))
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(subtitle)
    }

    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }
}
