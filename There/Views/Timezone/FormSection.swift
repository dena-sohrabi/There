import SwiftUI

struct FormSection: View {
    @Binding var name: String
    @Binding var city: String
    @Binding var selectedTimeZone: TimeZone?
    @Binding var isShowingPopover: Bool
    @StateObject var searchCompleter: SearchCompleter
    @Binding var countryEmoji: String
    @Binding var image: NSImage?
    @Binding var showingTGAccountInput: Bool
    @Binding var showingXAccountInput: Bool
    @State private var username = ""
    @State private var debounceTask: Task<Void, Never>?

    let saveEntry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            StyledLabel(title: "Name")
            Input(text: $name, placeholder: "eg. Dena or London Office")
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
                .popover(isPresented: $isShowingPopover) {
                    CitySearchResults(
                        searchCompleter: searchCompleter,
                        isShowingPopover: $isShowingPopover,
                        selectedCity: $city,
                        selectedTimezone: $selectedTimeZone,
                        countryEmoji: $countryEmoji
                    )
                }
            }

            if showingXAccountInput {
                SocialMediaInput(
                    platform: "X",
                    username: $username,
                    image: $image,
                    debounceTask: $debounceTask
                )
            } else if showingTGAccountInput {
                SocialMediaInput(
                    platform: "Telegram",
                    username: $username,
                    image: $image,
                    debounceTask: $debounceTask
                )
            }

            PrimaryButton(title: "Add", action: saveEntry)
                .padding(.top, 8)
        }
    }
}
