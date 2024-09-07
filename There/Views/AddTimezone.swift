import CoreLocation
import MapKit
import SwiftUI

struct AddTimezone: View {
    @Environment(\.database) private var database
    @StateObject private var searchCompleter = SearchCompleter()

    @State var image: NSImage?
    @State var name = ""
    @State var city = ""
    @State var selectedType: EntryType = .person
    @State var selectedTimeZone = TimeZone.current
    @State var isShowingPopover = false
    @State var countryEmoji = ""

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Heading(title: "Add Timezone")

            HStack(alignment: .top, spacing: 22) {
                IconView(
                    selectedType: selectedType,
                    image: $image,
                    countryEmoji: $countryEmoji
                )
                .padding(.top, 6)

                VStack(alignment: .leading, spacing: 2) {
                    StyledLabel(title: "Name")
                    Input(text: $name, placeholder: selectedType == .person ? "eg. Dena" : "eg. London Office")
                        .overlay(alignment: .trailingLastTextBaseline) {
                            TypePicker(selectedType: $selectedType)
                        }
                        .padding(.bottom, 6)

                    StyledLabel(title: "City")
                    Input(text: $city, placeholder: "eg. London")
                        .onChange(of: city) { newValue in
                            isShowingPopover = !city.isEmpty
                            if !city.isEmpty {
                                searchCompleter.search(newValue)
                            }
                        }
                        .popover(isPresented: $isShowingPopover, arrowEdge: .bottom) {
                            CitySearchResults(searchCompleter: searchCompleter, isShowingPopover: $isShowingPopover, city: $city, onSelect: searchPlace)
                        }

                    PrimaryButton(title: "Add") {
                        // TODO: Save entry
                    }
                    .padding(.top, 8)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    AddTimezone()
        .frame(width: 500, height: 400)
}
