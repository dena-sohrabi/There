import SwiftUI

struct EntryIcon: View {
    let entry: Entry
    @Environment(\.colorScheme) var scheme

    var backgroundColor: Color {
        if scheme == .dark {
            return Color(NSColor.darkGray)
        } else {
            return Color.white.opacity(0.6)
        }
    }

    var body: some View {
        Group {
            if entry.type == .place {
                placeIcon
            } else if let data = entry.photoData {
                photoIcon(data: data)
            } else {
                defaultIcon
            }
        }
        .overlay(alignment: .bottomTrailing) {
            timeIcon
        }
    }

    private var placeIcon: some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: 45)
            .overlay {
                Text(entry.flag ?? "✈️")
                    .font(.largeTitle)
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
                    .foregroundColor(.secondary)
                    .font(.largeTitle)
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
}
