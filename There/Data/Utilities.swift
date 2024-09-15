import Foundation
import SwiftUI

class Utils {
    public static var shared = Utils()
    func selectPhoto() -> NSImage? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.jpeg, .png]
        openPanel.allowsMultipleSelection = false
        openPanel.prompt = "Select Image"
        if openPanel.runModal() == .OK, let url = openPanel.url {
            return NSImage(contentsOf: url)
        } else {
            return nil
        }
    }

    /// Converts a two-letter country code to its corresponding emoji flag.
    ///
    /// - Parameter countryCode: ISO 3166-1 alpha-2 country code.
    /// - Returns: Emoji representation of the country's flag.
    func getCountryEmoji(for countryCode: String) -> String {
        // Unicode offset for Regional Indicator Symbols
        let base: UInt32 = 127397

        // Convert each letter to its corresponding Regional Indicator Symbol
        return countryCode.uppercased().unicodeScalars.map {
            String(UnicodeScalar(base + $0.value)!)
        }.joined()
    }
}
