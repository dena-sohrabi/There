import SwiftUI

struct LocationStatusView: View {
    let cityName: String?
    @State private var hovered: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "mappin.and.ellipse")
                .font(.caption)
            Text(cityName ?? "Unknown")
                .fontWeight(.semibold)
        }
        .foregroundColor(hovered ? (cityName != nil ? .green : .red) : .secondary)
        .onHover { hovering in
            withAnimation {
                hovered = hovering
            }
        }
        .frame(height: 30)
        .padding(.horizontal, 8)
        .background(hovered ? .white : .clear)
        .cornerRadius(8)
    }
}

#Preview {
    LocationStatusView(cityName: "New York")
}