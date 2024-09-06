import MapKit
import SwiftUI

struct ContentView: View {
    @AppStorage("email") var email: String = ""
    @StateObject private var locationManager = LocationManager()
    @StateObject private var fetcher = Fetcher()
    @State var hovered: [Int64: Bool] = [:]

    @State private var draggedCity: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Group {
                if fetcher.entries.isEmpty {
                    Text("Entries are empty")

                } else {
                    ForEach(fetcher.entries) { entry in
                        HStack {
                            Group {
                                if entry.type == .place {
                                    Circle()
                                        .fill(.white.opacity(0.6))
                                        .frame(width: 45)
                                        .overlay(alignment: .center) {
                                            Text(entry.flag ?? "✈️")
                                                .font(.largeTitle)
                                        }
                                } else if let url = URL(string: entry.photoData ?? "") {
                                    LocalImageView(imageURL: url)
                                        .frame(width: 45, height: 45)
                                        .clipShape(.circle)
                                } else {
                                    Circle()
                                        .fill(.green)
                                        .frame(width: 45)
                                }
                            }
                            .overlay(alignment: .bottomTrailing) {
                                Image(entry.timeIcon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 14, height: 14)
                                    .help(entry.timeIcon.replacingOccurrences(of: "-", with: " "))
                                    .background(
                                        TransparentBackgroundView()

                                            .frame(width: 18, height: 18)
                                            .cornerRadius(50)
                                    )
                                    .padding(.bottom, 4)
                                    .padding(.trailing, -3)
                            }
                            VStack(alignment: .leading) {
                                Text(entry.name)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                Text(entry.city)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 6)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(formattedTime(timeZoneIdentifier: entry.timezoneIdentifier))
                                    .monospaced()
                                    .font(.body)

                                HStack {
                                    Text(formatTimeDifference(hours: entry.timeDifference.hours, minutes: entry.timeDifference.minutes))
                                        .monospaced()
                                        .font(.body)
                                        .help(getDetailedTimeDifference(hours: entry.timeDifference.hours, minutes: entry.timeDifference.minutes))
                                        .foregroundColor(
                                            entry.timeDifference.hours < 0 || (entry.timeDifference.hours == 0 && entry.timeDifference.minutes < 0) ? .red
                                                : entry.timeDifference.hours == 0 && entry.timeDifference.minutes == 0 ? .gray
                                                : .green
                                        )
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(hovered[entry.id] ?? false ? .white.opacity(0.6) : .clear)
                        .cornerRadius(8)
                        .onHover { hovered in
                            withAnimation(.easeInOut(duration: 0.1)) {
                                self.hovered[entry.id] = hovered
                            }
                        }
//                        .draggable(entry.city) {
//                            Text(entry.city)
//                                .padding()
//                                .background(Color.white)
//                                .cornerRadius(8)
//                                .shadow(radius: 3)
//                        }
                        .onDrag {
                            self.draggedCity = entry.city
                            let provider = NSItemProvider(object: entry.city as NSString)
                            provider.suggestedName = "Open \(entry.city) in Maps"
                            return provider
                        }
                    }
                    .onDrop(of: [.text], isTargeted: nil) { providers -> Bool in
                        guard let provider = providers.first else { return false }

                        provider.loadObject(ofClass: String.self) { string, error in
                            guard let city = string as? String, error == nil else { return }
                            openInMaps(city: city)
                        }

                        return true
                    }

                    .padding(.horizontal, 6)
                }
            }

            LocationAccessView(authorizationStatus: locationManager.authorizationStatus)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            BottomBarView()
        }

        .onAppear {
            print("ContentView appeared")
            locationManager.checkLocationAuthorization()
        }
        .environmentObject(locationManager)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            if let city = draggedCity {
                openInMaps(city: city)
                draggedCity = nil
            }
        }
    }

    private func openInMaps(city: String) {
        let urlString = "maps://?q=\(city)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: urlString) else { return }

        let workspace = NSWorkspace.shared
        let mapsAppIdentifier = "com.apple.Maps"

        if let runningMapsApp = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == mapsAppIdentifier }) {
            runningMapsApp.activate(options: .activateIgnoringOtherApps)

            let script = """
            tell application "Maps"
                activate
                open location "\(city)"
            end tell
            """

            var error: NSDictionary?
            if let scriptObject = NSAppleScript(source: script) {
                scriptObject.executeAndReturnError(&error)
                if let error = error {
                    print("Error executing AppleScript: \(error)")
                }
            }
        } else {
            workspace.open(url)
        }
    }

    func formatTimeDifference(hours: Int, minutes: Int) -> String {
        if hours == 0 && minutes == 0 {
            return "Same time"
        }

        let totalHours = Double(hours) + Double(minutes) / 60.0
        let sign = totalHours < 0 ? "-" : "+"
        return String(format: "%@%.1f hrs", sign, abs(totalHours))
    }

    func getDetailedTimeDifference(hours: Int, minutes: Int) -> String {
        if hours == 0 && minutes == 0 {
            return "Same time"
        }

        var parts: [String] = []

        if abs(hours) > 0 {
            parts.append("\(abs(hours)) hour\(abs(hours) != 1 ? "s" : "")")
        }

        if abs(minutes) > 0 {
            parts.append("\(abs(minutes)) minute\(abs(minutes) != 1 ? "s" : "")")
        }

        let timeString = parts.joined(separator: " and ")
        let direction = hours < 0 || (hours == 0 && minutes < 0) ? "behind" : "ahead"

        return "\(timeString) \(direction)"
    }

    func formattedTime(timeZoneIdentifier: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        return formatter.string(from: Date())
    }
}

#Preview {
    ContentView()
        .frame(width: 300, height: 400)
}

struct LocalImageView: View {
    let imageURL: URL

    @State private var image: NSImage?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .onAppear(perform: loadImage)
    }

    private func loadImage() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            if let imageData = try? Data(contentsOf: imageURL),
               let loadedImage = NSImage(data: imageData) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load image"
                    self.isLoading = false
                }
            }
        }
    }
}
