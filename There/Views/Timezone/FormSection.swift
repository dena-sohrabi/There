import PostHog
import SwiftUI
import UserNotifications

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
    @State var showError: Bool = false
    @State private var username = ""
    @State private var debounceTask: Task<Void, Never>?
    var isEditing: Bool = false
    let saveEntry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            StyledLabel(title: "Name")
            Input(text: $name, placeholder: "eg. Dena or London Office")
                .padding(.bottom, 6)
                .onSubmit {
                    if !city.isEmpty {
                        PostHogSDK.shared.capture("timezone_added")
                        saveEntry()
                    } else {
                        withAnimation(.easeIn(duration: 0.1)) {
                            showError = true
                        }
                    }
                }
            if !city.isEmpty {
                SecondaryButton(title: city) {
                    withAnimation(.easeOut(duration: 0.1)) {
                        showError = false
                    }
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
            } else {
                SecondaryButton(title: "Set location / timezone") {
                    withAnimation(.easeOut(duration: 0.1)) {
                        showError = false
                    }
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

            if showError {
                Text("please select a Location")
                    .font(.caption)
                    .foregroundColor(.red)
                    .fontWeight(.medium)
                    .transition(.opacity)
            }

            PrimaryButton(title: isEditing ? "Update" : "Add", action: {
                if !city.isEmpty {
                    saveEntry()
                    PostHogSDK.shared.capture("timezone_added")
                } else {
                    withAnimation(.easeIn(duration: 0.1)) {
                        showError = true
                    }
                }

            })
            .disabled(city.isEmpty)
            .opacity(city.isEmpty ? 0.6 : 1)
            .padding(.top, 8)
        }
    }
}
