import CoreLocation
import SwiftUI

struct EntryIcon: View {
    let entry: Entry
    @Environment(\.colorScheme) var scheme
    @Environment(\.database) var database
    @State private var useClockIcon: Bool = false

    var backgroundColor: Color {
        if scheme == .dark {
            return Color(NSColor.darkGray)
        } else {
            return Color.white.opacity(0.6)
        }
    }

    var body: some View {
        Group {
            if let data = entry.photoData, !data.isEmpty {
                photoIcon(data: data)
            } else if let flag = entry.flag, !flag.isEmpty {
                placeIcon
            } else {
                defaultIcon
            }
        }
        .overlay(alignment: .bottomTrailing) {
            timeIcon
        }
        .onAppear {
            if entry.flag == nil || entry.flag!.isEmpty {
                searchForFlag()
            }
        }
    }

    private var placeIcon: some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: 45)
            .overlay {
                if let flag = entry.flag {
                    Text(flag)
                        .font(.largeTitle)
                } else {
                    Image(systemName: "clock")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
            }
    }

    private func photoIcon(data: String) -> some View {
        Group {
            if let url = URL(string: data) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                    case .failure:
                        defaultIcon
                    case .empty:
                        ProgressView()
                    @unknown default:
                        defaultIcon
                    }
                }
            } else {
                defaultIcon
            }
        }
    }

    private var defaultIcon: some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: 45)
            .overlay {
                Image(systemName: "clock")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            }
    }

    private var timeIcon: some View {
        Image(entry.timeIcon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 14, height: 14)
            .background(
                TransparentBackgroundView()
                    .frame(width: 18, height: 18)
                    .cornerRadius(50)
            )
            .padding(.bottom, 4)
            .padding(.trailing, -3)
    }

    func searchForFlag() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(entry.city) { placemarks, _ in
            if let placemark = placemarks?.first, let timezone = placemark.timeZone {
                Task {
                    do {
                        try await database.dbWriter.write { db in
                            var entry = try Entry.fetchOne(db, id: entry.id)
                            let countryEmoji = Utils.shared.getCountryEmoji(for: placemark.isoCountryCode ?? "")
                            entry?.flag = countryEmoji.isEmpty ? "🌍" : countryEmoji
                            try entry?.update(db)
                        }
                    } catch {
                        print("Can't find flag \(error)")
                    }
                }
            }
        }
    }
}
