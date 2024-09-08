import MapKit
import SwiftUI

class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [SearchResult] = []
    @Published var queryFragment: String = "" {
        didSet {
            if queryFragment.isEmpty {
                results = defaultResults
            } else {
                completer.queryFragment = queryFragment
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
            defaultResults.append(SearchResult(title: "UTC\(sign)\(offset)", subtitle: "Coordinated Universal Time \(sign)\(offset)"))
        }

        // All timezones and locations
        for identifier in TimeZone.knownTimeZoneIdentifiers {
            let components = identifier.split(separator: "/")
            if components.count >= 2 {
                let location = String(components.last!).replacingOccurrences(of: "_", with: " ")
                let region = String(components.first!)
                defaultResults.append(SearchResult(title: location, subtitle: region))
            }
        }

        
        defaultResults.append(SearchResult(title: "SF, CA", subtitle: "United States"))

        results = defaultResults
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results.map { SearchResult(title: $0.title, subtitle: $0.subtitle) }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}
