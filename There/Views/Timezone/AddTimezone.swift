import CoreLocation
import MapKit
import SwiftUI

struct AddTimezone: View {
    @Environment(\.database) var database
    @StateObject private var searchCompleter = SearchCompleter()
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    @State var image: NSImage?
    @State var name = ""
    @State var city = ""
    @State var selectedType: EntryType = .person
    @State var selectedTimeZone: TimeZone? = nil
    @State var isShowingPopover = false
    @State var countryEmoji = ""

    @State var showingXAccountInput = false
    @State var showingTGAccountInput = false

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .top, spacing: 35) {
                IconSection(
                    selectedType: $selectedType,
                    image: $image,
                    countryEmoji: $countryEmoji,
                    showingXAccountInput: $showingXAccountInput,
                    showingTGAccountInput: $showingTGAccountInput
                )

                FormSection(
                    name: $name,
                    city: $city,
                    selectedType: $selectedType,
                    selectedTimeZone: $selectedTimeZone,
                    isShowingPopover: $isShowingPopover,
                    searchCompleter: searchCompleter,
                    countryEmoji: $countryEmoji,
                    image: $image,
                    showingTGAccountInput: $showingTGAccountInput,
                    showingXAccountInput: $showingXAccountInput,
                    saveEntry: saveEntry
                )
            }
        }
        .frame(maxHeight: .infinity)
        .padding()

        .onChange(of: countryEmoji) { newValue in
            print("countryEmoji changed: \(newValue)")
        }
        .overlay(alignment: .top) {
            Heading(title: "Add Timezone").padding()
        }
    }
}

#Preview {
    AddTimezone()
        .frame(width: 500, height: 400)
}
