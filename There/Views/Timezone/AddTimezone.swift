import CoreLocation
import MapKit
import SwiftUI

struct AddTimezone: View {
    @Environment(\.database) var database
    @StateObject private var searchCompleter = SearchCompleter()

    @EnvironmentObject var router: Router

    @State var image: NSImage?
    @State var name = ""
    @State var city = ""
    @State var selectedTimeZone: TimeZone? = nil
    @State var isShowingPopover = false
    @State var countryEmoji = ""

    @State var showingXAccountInput = false
    @State var showingTGAccountInput = false

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
//            HStack(alignment: .top, spacing: 35) {
            IconSection(
                image: $image,
                countryEmoji: $countryEmoji,
                showingXAccountInput: $showingXAccountInput,
                showingTGAccountInput: $showingTGAccountInput
            )

            FormSection(
                name: $name,
                city: $city,
                selectedTimeZone: $selectedTimeZone,
                isShowingPopover: $isShowingPopover,
                searchCompleter: searchCompleter,
                countryEmoji: $countryEmoji,
                image: $image,
                showingTGAccountInput: $showingTGAccountInput,
                showingXAccountInput: $showingXAccountInput,
                saveEntry: saveEntry
            )
//            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding()

        .onChange(of: countryEmoji) { newValue in
            print("countryEmoji changed: \(newValue)")
        }
        .overlay(alignment: .topLeading) {
            Titlebar()
                .padding(6)
        }
    }
}

#Preview {
    AddTimezone()
        .frame(width: 300, height: 400)
}
