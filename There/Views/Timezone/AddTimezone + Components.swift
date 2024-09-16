import AppKit
import MapKit
import SwiftUI

// MARK: - IconView

struct IconView: View {
    @Binding var image: NSImage?
    @Binding var countryEmoji: String

    @State private var showPopover = false
    @State private var isDropTargeted = false
    @State private var showingXAccountInput = false
    @State private var showingTGAccountInput = false
    @State private var username = ""
    @State private var debounceTask: Task<Void, Never>?

    var body: some View {
        iconContent
            .frame(width: 70, height: 70)
            .onTapGesture { showPopover = true }
            .popover(isPresented: $showPopover) { popoverContent }
    }

    private var iconContent: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } else if !countryEmoji.isEmpty {
                flagView
            } else {
                placeholderView
            }
        }
    }

    private var flagView: some View {
        Circle()
            .fill(.white)
            .overlay(Text(countryEmoji).font(.largeTitle))
    }

    private var placeholderView: some View {
        Circle()
            .fill(.gray.opacity(0.1))
            .overlay(
                Image(systemName: "photo.badge.plus")
                    .font(.title)
                    .foregroundColor(.gray.opacity(0.8))
            )
    }

    private var popoverContent: some View {
        VStack {
            importButtons

            if showingXAccountInput {
                SocialMediaInput(platform: "X", username: $username, image: $image, debounceTask: $debounceTask)
                    .onSubmit {
                        showPopover = false
                    }
            } else if showingTGAccountInput {
                SocialMediaInput(platform: "Telegram", username: $username, image: $image, debounceTask: $debounceTask)
                    .onSubmit {
                        showPopover = false
                    }
            }
        }
        .padding()
    }

    private var importButtons: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("Set from").foregroundColor(.secondary)
            Button("Telegram") {
                showingXAccountInput = false
                showingTGAccountInput = true
            }
            .buttonStyle(.link)
            .padding(.horizontal, 2)
            Text("/").foregroundColor(.secondary).padding(.horizontal, 2)
            Button("X") {
                showingTGAccountInput = false
                showingXAccountInput = true
            }
            .buttonStyle(.link)
            .padding(.horizontal, 2)
            Text("/").foregroundColor(.secondary).padding(.horizontal, 2)
            Button("Finder") {
                let selectedImage = Utils.shared.selectPhoto()
                DispatchQueue.main.async {
                    self.image = selectedImage
                }

            }.buttonStyle(.link).padding(.horizontal, 2)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadObject(ofClass: NSImage.self) { object, _ in
            if let image = object as? NSImage {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
        return true
    }
}

// MARK: - CitySearchResults

struct CitySearchResults: View {
    @ObservedObject var searchCompleter: SearchCompleter
    @Binding var isShowingPopover: Bool
    @Binding var selectedCity: String
    @Binding var selectedTimezone: TimeZone?
    @Binding var countryEmoji: String
    @FocusState private var isFocused: Bool
    @State private var selectedIndex: Int = -1

    var body: some View {
        VStack(spacing: 0) {
            CustomTextField(text: $searchCompleter.queryFragment, placeholder: "Search for a city or timezone", onKeyDown: handleKeyEvent)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 6)
                .frame(width: 280, height: 32)
                .background(AdaptiveColors.textFieldBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isFocused ? .blue : AdaptiveColors.textFieldBorder.opacity(0.5), lineWidth: 1)
                )
                .focused($isFocused)
                .foregroundColor(AdaptiveColors.textColor)
                .padding(.vertical)

            ScrollViewReader { proxy in
                List(searchCompleter.results.indices, id: \.self) { index in
                    let result = searchCompleter.results[index]
                    Button(action: {
                        selectCity(result)
                    }) {
                        VStack(alignment: .leading) {
                            Text(result.title)
                            Text(result.subtitle ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(selectedIndex == index ? Color.accentColor.opacity(0.1) : Color.clear)
                    .id(index)
                }
                .listStyle(PlainListStyle())
                .onChange(of: selectedIndex) { newValue in
                    if newValue >= 0 {
                        // This handles all scrolling scenarios, including scrolling to the bottom
                        // when the last item is selected:
                        // 1. It triggers whenever selectedIndex changes.
                        // 2. It scrolls to the newly selected item if it's in the list (index >= 0).
                        // 3. The .center anchor attempts to center the item in the visible area.
                        // 4. For the last item, this effectively scrolls to the bottom of the list.
                        // 5. It also ensures that the selected item is always visible, even if it's
                        //    not the last item.
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
        .frame(width: 300, height: 400)
    }

    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        switch event.keyCode {
        case 126: // Up arrow
            moveSelection(direction: .up)
            return true
        case 125: // Down arrow
            moveSelection(direction: .down)
            return true
        case 36: // Return key
            if selectedIndex >= 0 && selectedIndex < searchCompleter.results.count {
                selectCity(searchCompleter.results[selectedIndex])
            }
            return true
        default:
            return false
        }
    }

    private func moveSelection(direction: KeyboardNavigationDirection) {
        let itemCount = searchCompleter.results.count
        switch direction {
        case .up:
            if selectedIndex > 0 {
                // If not at the top of the list, move up one item
                selectedIndex -= 1
            } else if selectedIndex == 0 {
                // If at the top of the list, move focus to the search field
                selectedIndex = -1
            } else if selectedIndex == -1 {
                // If focus is on the search field, move to the bottom of the list
                selectedIndex = itemCount - 1
            }
        case .down:
            if selectedIndex == -1 {
                // If focus is on the search field and there are items, select the first item
                if itemCount > 0 {
                    selectedIndex = 0
                }
            } else if selectedIndex < itemCount - 1 {
                // If not at the bottom of the list, move down one item
                selectedIndex += 1
            } else if selectedIndex == itemCount - 1 {
                // If at the bottom of the list, move focus back to the search field
                selectedIndex = -1
            }
        case .enter:
            // Enter key handling is done elsewhere
            break
        }
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
                    countryEmoji = Utils.shared.getCountryEmoji(for: placemark.isoCountryCode ?? "")
                }
            }
        }

        isShowingPopover = false
    }
}

struct CustomTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onKeyDown: (NSEvent) -> Bool

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.placeholderString = placeholder
        textField.delegate = context.coordinator
        textField.focusRingType = .none
        textField.drawsBackground = true
        textField.backgroundColor = .white
        textField.isBordered = false
        textField.textColor = .black
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: CustomTextField

        init(_ parent: CustomTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                parent.text = textField.stringValue
            }
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.moveUp(_:)) {
                return parent.onKeyDown(NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: 126)!)
            } else if commandSelector == #selector(NSResponder.moveDown(_:)) {
                return parent.onKeyDown(NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: 125)!)
            } else if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                return parent.onKeyDown(NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil, characters: "\r", charactersIgnoringModifiers: "\r", isARepeat: false, keyCode: 36)!)
            }
            return false
        }
    }
}

enum KeyboardNavigationDirection {
    case up, down, enter
}
