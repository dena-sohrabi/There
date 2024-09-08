import SwiftUI

struct FormSection: View {
    @Binding var name: String
    @Binding var city: String
    @Binding var selectedType: EntryType
    @Binding var selectedTimeZone: TimeZone?
    @Binding var isShowingPopover: Bool
    @StateObject var searchCompleter: SearchCompleter
    @Binding var countryEmoji: String
    @Binding var image: NSImage?
    let saveEntry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            StyledLabel(title: "Name")
            Input(text: $name, placeholder: selectedType == .person ? "eg. Dena" : "eg. London Office")
                .overlay(alignment: .trailingLastTextBaseline) {
                    TypePicker(selectedType: $selectedType)
                }
                .padding(.bottom, 6)

            if !city.isEmpty {
                SecondaryButton(title: city) {
                    isShowingPopover = true
                }
                .sheet(isPresented: $isShowingPopover) {
                    CitySearchResults(
                        searchCompleter: searchCompleter,
                        isShowingPopover: $isShowingPopover,
                        selectedCity: $city,
                        selectedTimezone: $selectedTimeZone,
                        countryEmoji: $countryEmoji
                    )
                }
            } else {
                SecondaryButton(title: "Add Location") {
                    isShowingPopover = true
                }
                .sheet(isPresented: $isShowingPopover) {
                    CitySearchResults(
                        searchCompleter: searchCompleter,
                        isShowingPopover: $isShowingPopover,
                        selectedCity: $city,
                        selectedTimezone: $selectedTimeZone,
                        countryEmoji: $countryEmoji
                    )
                }
            }

            PrimaryButton(title: "Add", action: saveEntry)
                .padding(.top, 8)
        }
    }
}
