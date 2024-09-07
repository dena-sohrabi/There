import MapKit
import SwiftUI

// MARK: - TypePicker

struct TypePicker: View {
    @Binding var selectedType: EntryType

    var body: some View {
        Picker(selection: $selectedType) {
            Image(systemName: "mappin.and.ellipse")
                .tag(EntryType.place)
            Image(systemName: "person.fill")
                .tag(EntryType.person)
        } label: {}
            .fixedSize()
            .pickerStyle(.menu)
            .menuStyle(.button)
            .menuIndicator(.hidden)
            .help("\(selectedType)")
            .padding(.trailing, 6)
    }
}

// MARK: - IconView

struct IconView: View {
    let selectedType: EntryType
    @Binding var image: NSImage?
    @Binding var countryEmoji: String

    var body: some View {
        Group {
            if selectedType == .place {
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
                    .fill(.blue.opacity(0.1))
                    .frame(width: 65, height: 65)
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
}

// MARK: - FlagView

struct FlagView: View {
    let countryEmoji: String

    var body: some View {
        Circle()
            .fill(.purple.opacity(0.1))
            .frame(width: 65, height: 65)
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
}

// MARK: - CitySearchResults

struct CitySearchResults: View {
    @ObservedObject var searchCompleter: SearchCompleter
    @Binding var isShowingPopover: Bool
    @Binding var city: String
    let onSelect: (MKLocalSearchCompletion) -> Void

    var body: some View {
        Group {
            if !searchCompleter.results.isEmpty {
                List(searchCompleter.results) { result in
                    Text("\(result.title), \(result.subtitle)")
                        .onTapGesture {
                            isShowingPopover = false
                            city = result.title
                            onSelect(result.completion)
                        }
                }
                .frame(height: min(CGFloat(searchCompleter.results.count) * 44, 200))
            } else {
                Text("Searching for city...")
                    .frame(width: 200, height: 32)
            }
        }
    }
}
