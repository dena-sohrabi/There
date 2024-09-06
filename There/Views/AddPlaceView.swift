import CoreLocation
import MapKit
import SwiftUI

struct AddPlaceView: View {
    @State private var name = ""
    @State private var city = ""
    @State private var country = ""
    @State private var countryEmoji = ""
    @State private var selectedTimeZone = TimeZone.current
    @StateObject private var searchCompleter = SearchCompleter()
    @State private var isShowingPopover = false

    @Environment(\.database) private var database

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text("Add a Place Timezone")
                .fontWeight(.semibold)
                .font(.title)
                .padding(.bottom, 18)

            HStack(alignment: .top) {
                flagView
                Input(text: $name, placeholder: "place name")
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

    private var flagView: some View {
        Circle()
            .fill(.purple.opacity(0.1))
            .frame(width: 35, height: 35)
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
                        self.countryEmoji = self.getCountryEmoji(for: placemark.isoCountryCode ?? "")
                    }
                }
            }
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

    private func saveEntry() {
        do {
            try database.dbWriter.write { db in
                let entry = Entry(
                    id: Int64.random(in: 1 ... 99999),
                    type: .place,
                    name: name,
                    city: city,
                    country: country,
                    timezoneIdentifier: selectedTimeZone.identifier,
                    flag: countryEmoji,
                    photoData: nil
                )
                try entry.save(db)
            }
            resetForm()
        } catch {
            print("Failed to save entry: \(error)")
        }
    }

    private func resetForm() {
        name = ""
        city = ""
        country = ""
        countryEmoji = ""
        selectedTimeZone = TimeZone.current
    }
}
