import CoreLocation
import MapKit
import SwiftUI

/// Represents a search result with additional information
struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let completion: MKLocalSearchCompletion
}

/// A class that handles location search completions
class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    /// Published array of search results
    @Published var results: [SearchResult] = []

    /// The MKLocalSearchCompleter instance used for generating search suggestions
    private let completer: MKLocalSearchCompleter

    /// Initializes the SearchCompleter
    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    /// Initiates a search with the given query
    /// - Parameter query: The search query string
    func search(_ query: String) {
        completer.queryFragment = query
    }

    /// Delegate method called when the completer updates its results
    /// - Parameter completer: The MKLocalSearchCompleter that updated its results
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Map the MKLocalSearchCompletion results to our custom SearchResult struct
        results = completer.results.map { completion in
            SearchResult(
                title: completion.title,
                subtitle: completion.subtitle,
                completion: completion
            )
        }
    }

    /// Delegate method called when the completer encounters an error
    /// - Parameters:
    ///   - completer: The MKLocalSearchCompleter that encountered an error
    ///   - error: The error that occurred
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
