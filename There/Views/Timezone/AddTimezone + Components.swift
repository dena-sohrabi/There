import MapKit
import SwiftUI

// MARK: - IconView

struct IconView: View {
    @Binding var image: NSImage?
    @Binding var countryEmoji: String

    var body: some View {
        Group {
            if image != nil {
                ImageView(image: $image)
            } else if !countryEmoji.isEmpty {
                FlagView(countryEmoji: countryEmoji)
            } else {
                ImageView(image: $image)
            }
        }
    }
}

// MARK: - ImageView

struct ImageView: View {
    @Binding var image: NSImage?

    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 65, height: 65)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(.gray.opacity(0.1))
                    .frame(width: 65, height: 65)
                    .overlay(alignment: .center) {
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundColor(.gray.opacity(0.8))
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
}

// MARK: - FlagView

struct FlagView: View {
    let countryEmoji: String

    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: 65, height: 65)
            .overlay(alignment: .center) {
                if !countryEmoji.isEmpty {
                    Text(countryEmoji)
                        .font(.largeTitle)
                } else {
                    Image(systemName: "flag")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
    }
}

// MARK: - CitySearchResults

struct CitySearchResults: View {
    @ObservedObject var searchCompleter: SearchCompleter
    @Binding var isShowingPopover: Bool
    @Binding var selectedCity: String
    @Binding var selectedTimezone: TimeZone?
    @Binding var countryEmoji: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                CompactInput(text: $searchCompleter.queryFragment, placeholder: "Search for a city or timezone")
                    .frame(maxWidth: 210)
                    .frame(minWidth: 210)
                Spacer()
                Button("dismiss") {
                    isShowingPopover = false
                }
                .buttonStyle(.borderless)
                .foregroundColor(.blue)
            }
            .padding(.top)
            .padding(.horizontal)

            List(searchCompleter.results) { result in
                Button(action: {
                    selectCity(result)
                }) {
                    VStack(alignment: .leading) {
                        Text(result.title)
                        Text(result.subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .clipShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 300, height: 400)
    }

    private func selectCity(_ result: SearchResult) {
        selectedCity = "\(result.title), \(result.subtitle)"

        if result.title.starts(with: "UTC") {
            let offsetString = result.title.dropFirst(3)
            if let offset = Int(offsetString) {
                selectedTimezone = TimeZone(secondsFromGMT: offset * 3600)
            }
        } else {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(selectedCity) { placemarks, _ in
                if let placemark = placemarks?.first, let timezone = placemark.timeZone {
                    selectedTimezone = timezone
                    countryEmoji = getCountryEmoji(for: placemark.isoCountryCode ?? "")
                    print(countryEmoji)
                }
            }
        }

        isShowingPopover = false
    }
}
