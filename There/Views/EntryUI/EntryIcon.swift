import SwiftUI

struct EntryIcon: View {
    let entry: Entry

    var body: some View {
        Group {
            if entry.type == .place {
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 45)
                    .overlay {
                        Text(entry.flag ?? "✈️")
                            .font(.largeTitle)
                    }
            } else if let url = URL(string: entry.photoData ?? "") {
                LocalImageView(imageURL: url)
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.green)
                    .frame(width: 45)
            }
        }
        .overlay(alignment: .bottomTrailing) {
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
}
