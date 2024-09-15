import AppKit
import CoreLocation
import Foundation
import MapKit
import SwiftUI

extension EditTimeZoneView {
    func saveEntry() {
        let fileName = UUID().uuidString + ".png"
        let fileURL = getApplicationSupportDirectory().appendingPathComponent(fileName)

        if let tiffData = image?.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapImage.representation(using: .png, properties: [:]) {
            do {
                try pngData.write(to: fileURL)
            } catch {
                print("Failed to save image: \(error)")
            }
        }

        do {
            try database.dbWriter.write { db in
                if let entry = entry {
                    let entry = Entry(
                        id: entry.id,
                        type: !countryEmoji.isEmpty && image == nil ? .place : .person,
                        name: name,
                        city: city,
                        timezoneIdentifier: selectedTimeZone?.identifier ?? "",
                        flag: image == nil ? countryEmoji : "",
                        photoData: fileURL.absoluteString
                    )
                    try entry.save(db)
                }
            }
        } catch {
            print("Failed to save entry \(error)")
        }

        router.cleanActiveRoute()
    }

    private func getApplicationSupportDirectory() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }
}
