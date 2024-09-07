import CoreLocation
import MapKit
import SwiftUI

struct AddTimezone: View {
    @Environment(\.database) private var database
    @StateObject private var searchCompleter = SearchCompleter()

    @State private var image: NSImage?
    @State private var name = ""
    @State private var city = ""
    @State private var selectedType: EntryType = .person
    @State private var selectedTimeZone = TimeZone.current
    @State private var isShowingPopover = false
    @State private var countryEmoji = ""

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Add Timezone")
                .fontWeight(.semibold)
                .font(.title)
                .padding(.bottom, 18)

            HStack(alignment: .top) {
                if selectedType == .place {
                    flagView
                } else {
                    imageView
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Input(text: $name, placeholder: selectedType == .person ? "eg. Dena" : "eg. London Office")
//                        .frame(maxWidth: 245)
                        .overlay(alignment: .trailingFirstTextBaseline) {
                            Picker(selection: $selectedType) {
                                Image(systemName: "mappin.and.ellipse")
                                    .tag(EntryType.place)
                                Image(systemName: "person.fill")
                                    .tag(EntryType.person)
                            } label: {
                            }
                            .fixedSize()
                            .pickerStyle(.menu)
                            .menuStyle(.button)
                            .menuIndicator(.hidden)
                            .help("\(selectedType)")
                            .padding(.trailing, 6)
                        }
                    Text("City")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Input(text: $city, placeholder: "eg. London")
//                        .frame(maxWidth: 245)
                        .onChange(of: city) { newValue in
                            isShowingPopover = !city.isEmpty
                            if !city.isEmpty {
                                searchCompleter.search(newValue)
                            }
                        }
                        .popover(isPresented: $isShowingPopover, arrowEdge: .bottom) {
                            citySearchResults
                        }
                    PrimaryButton(title: "Add") {
                    }
                }
            }
        }
//        .frame(width: 300)
        .frame(maxHeight: .infinity)
        .padding()
    }

    private var imageView: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 55, height: 55)
                    .overlay(alignment: .center) {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.blue.opacity(0.8))
                    }
            }
        }
        .onTapGesture(perform: selectPhoto)
    }

    private func selectPhoto() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.image]
        openPanel.allowsMultipleSelection = false

        if openPanel.runModal() == .OK, let url = openPanel.url {
            image = NSImage(contentsOf: url)
        }
    }

    private func getCountryEmoji(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            emoji.unicodeScalars.append(UnicodeScalar(base + scalar.value)!)
        }
        return emoji
    }

    private var flagView: some View {
        Circle()
            .fill(.purple.opacity(0.1))
            .frame(width: 55, height: 55)
            .overlay(alignment: .center) {
                if !countryEmoji.isEmpty {
                    Text(countryEmoji)
                        .font(.title3)
                } else {
                    Image(systemName: "flag")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple.opacity(0.8))
                }
            }
    }

    private var citySearchResults: some View {
        Group {
            if !searchCompleter.results.isEmpty {
                List(searchCompleter.results) { result in
                    Text("\(result.title), \(result.subtitle)")
                        .onTapGesture {
                            isShowingPopover = false
                            city = result.title
                            searchPlace(result.completion)
                        }
                }
                .frame(height: min(CGFloat(searchCompleter.results.count) * 44, 200))
            } else {
                Text("Searching for city...")
                    .frame(width: 200, height: 32)
            }
        }
    }

    private func searchPlace(_ completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, _ in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }

            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
                DispatchQueue.main.async {
                    if let placemark = placemarks?.first {
                        if let timeZone = placemark.timeZone {
                            self.selectedTimeZone = timeZone
                        }
                        self.countryEmoji = self.getCountryEmoji(for: placemark.isoCountryCode ?? "")
                    }
                }
            }
        }
    }
}

#Preview {
    AddTimezone()
        .frame(width: 400, height: 400)
}
