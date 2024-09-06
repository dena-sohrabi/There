import CoreLocation
import MapKit
import SwiftUI

struct AddPersonView: View {
    @State private var name = ""
    @State private var city = ""
    @State private var country = ""
    @State private var image: NSImage?
    @State private var selectedTimeZone = TimeZone.current
    @StateObject private var searchCompleter = SearchCompleter()
    @State private var isShowingPopover = false

    @Environment(\.database) private var database

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text("Add a Person Timezone")
                .fontWeight(.semibold)
                .font(.title)
                .padding(.bottom, 18)

            HStack(alignment: .top) {
                imageView
                Input(text: $name, placeholder: "name")
            }

            cityInput

            CompactInput(text: $country, placeholder: "country")
                .frame(maxWidth: 245, maxHeight: 32)

            CompactPrimaryButton(title: "Add", action: saveEntry)
        }
        .frame(width: 300)
        .frame(maxHeight: .infinity)
        .padding()
    }

    private var imageView: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 35, height: 35)
                    .overlay(alignment: .center) {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.blue.opacity(0.8))
                    }
            }
        }
        .onTapGesture(perform: selectPhoto)
    }

    private var cityInput: some View {
        CompactInput(text: $city, placeholder: "city")
            .frame(maxWidth: 245, maxHeight: 32)
            .onChange(of: city) { newValue in
                isShowingPopover = !city.isEmpty
                if !city.isEmpty {
                    searchCompleter.search(newValue)
                }
            }
            .popover(isPresented: $isShowingPopover, arrowEdge: .bottom) {
                citySearchResults
            }
    }

    private var citySearchResults: some View {
        Group {
            if !searchCompleter.results.isEmpty {
                List(searchCompleter.results, id: \.self) { result in
                    Text(result.title)
                        .onTapGesture {
                            isShowingPopover = false
                            city = result.title
                            searchPlace(result)
                        }
                }
                .frame(height: min(CGFloat(searchCompleter.results.count) * 44, 200))
            } else {
                Text("Searching for city...")
                    .frame(width: 200, height: 32)
            }
        }
    }

    private func selectPhoto() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.image]
        openPanel.allowsMultipleSelection = false

        if openPanel.runModal() == .OK, let url = openPanel.url {
            image = NSImage(contentsOf: url)
        }
    }

    private func saveEntry() {
        guard let image = image else { return }

        let fileName = UUID().uuidString + ".png"
        let fileURL = getApplicationSupportDirectory().appendingPathComponent(fileName)

        if let tiffData = image.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapImage.representation(using: .png, properties: [:]) {
            do {
                try pngData.write(to: fileURL)

                do {
                    try database.dbWriter.write { db in
                        let entry = Entry(
                            id: Int64.random(in: 1 ... 99999),
                            type: .person,
                            name: name,
                            city: city,
                            country: country,
                            timezoneIdentifier: selectedTimeZone.identifier,
                            flag: nil,
                            photoData: fileURL.absoluteString
                        )
                        try entry.save(db)
                    }
                } catch {
                    print("Failed to save entry \(error)")
                }

                resetForm()
            } catch {
                print("Failed to save image: \(error)")
            }
        }
    }

    private func resetForm() {
        name = ""
        city = ""
        country = ""
        image = nil
    }

    private func getApplicationSupportDirectory() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }

    private func searchPlace(_ result: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, _ in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }

            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
                DispatchQueue.main.async {
                    if let placemark = placemarks?.first {
                        self.country = placemark.country ?? ""
                        if let timeZone = placemark.timeZone {
                            self.selectedTimeZone = timeZone
                        }
                    }
                }
            }
        }
    }
}
