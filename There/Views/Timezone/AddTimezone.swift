import CoreLocation
import MapKit
import SwiftUI

struct AddTimezone: View {
    @Environment(\.database) var database
    @StateObject private var searchCompleter = SearchCompleter()

    @State var image: NSImage?
    @State var name = ""
    @State var city = ""
    @State var selectedType: EntryType = .person
    @State var selectedTimeZone: TimeZone? = nil
    @State var isShowingPopover = false
    @State var countryEmoji = ""

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Heading(title: "Add Timezone")

            HStack(alignment: .top, spacing: 35) {
                IconSection(
                    selectedType: $selectedType,
                    image: $image,
                    countryEmoji: $countryEmoji
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
                    saveEntry: saveEntry
                )
            }
        }
        .frame(maxHeight: .infinity)
        .padding()
        .onChange(of: countryEmoji) { _, newValue in
            print("countryEmoji changed: \(newValue)")
        }
    }
}

#Preview {
    AddTimezone()
        .frame(width: 500, height: 400)
}
