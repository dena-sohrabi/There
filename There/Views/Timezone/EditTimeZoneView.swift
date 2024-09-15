import CoreLocation
import MapKit
import SwiftUI

struct EditTimeZoneView: View {
    var entryId: Int64?
    @Environment(\.database) var database
    @StateObject private var searchCompleter = SearchCompleter()
    @EnvironmentObject var router: Router

    @State var entry: Entry?
    @State var image: NSImage?
    @State var name = ""
    @State var city = ""
    @State var selectedTimeZone: TimeZone?
    @State var isShowingPopover = false
    @State var countryEmoji = ""

    @State var showingXAccountInput = false
    @State var showingTGAccountInput = false

    @State var isLoading = true
    @State var errorMessage: String?

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if isLoading {
                ProgressView()
            } else if let entry = entry {
                IconSection(
                    image: $image,
                    countryEmoji: $countryEmoji,
                    showingXAccountInput: $showingXAccountInput,
                    showingTGAccountInput: $showingTGAccountInput
                )

                FormSection(
                    name: $name,
                    city: $city,
                    selectedTimeZone: $selectedTimeZone,
                    isShowingPopover: $isShowingPopover,
                    searchCompleter: searchCompleter,
                    countryEmoji: $countryEmoji,
                    image: $image,
                    showingTGAccountInput: $showingTGAccountInput,
                    showingXAccountInput: $showingXAccountInput,
                    isEditing: true,
                    saveEntry: saveEntry
                )
            } else {
                NotFoundView()
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            Titlebar()
                .padding(6)
        }
        .task {
            await loadEntry()
        }
    }

    private func loadEntry() async {
        isLoading = true
        do {
            try await database.reader.read { db in
                if let id = entryId {
                    let fetchedEntry = try Entry.fetchOne(db, id: id)
                    self.entry = fetchedEntry
                    if let entry = fetchedEntry {
                        self.name = entry.name
                        self.city = entry.city
                        self.selectedTimeZone = TimeZone(identifier: entry.timezoneIdentifier)
                        self.countryEmoji = entry.flag ?? ""
                        if entry.photoData != nil, let imageURL = URL(string: entry.photoData!) {
                            if let imageData = try? Data(contentsOf: imageURL) {
                                self.image = NSImage(data: imageData)
                            } else {
                                print("Failed to load image data from URL: \(imageURL)")
                            }
                        } else {
                            self.image = nil
                        }
                    }
                }
            }
        } catch {
            errorMessage = "Failed to load entry: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

#Preview {
    EditTimeZoneView(entryId: 1712)
        .frame(width: 300, height: 400)
        .environment(\.database, .shared)
}
