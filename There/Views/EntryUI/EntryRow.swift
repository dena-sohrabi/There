import SwiftUI

struct EntryRow: View {
    let entry: Entry
    @State private var isHovered: Bool = false

    var body: some View {
        HStack {
            EntryIcon(entry: entry)
            VStack(alignment: .leading) {
                Text(entry.name)
                    .font(.title3)
                    .fontWeight(.medium)
                Text(entry.city)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.leading, 6)
            Spacer()
            VStack(alignment: .trailing) {
                Text(formattedTime(timeZoneIdentifier: entry.timezoneIdentifier))
                    .monospaced()
                    .font(.body)
                Text(formatTimeDifference(hours: entry.timeDifference.hours, minutes: entry.timeDifference.minutes))
                    .monospaced()
                    .font(.body)
                    .foregroundColor(timeDifferenceColor(hours: entry.timeDifference.hours, minutes: entry.timeDifference.minutes))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isHovered ? Color.white.opacity(0.6) : Color.clear)
        .cornerRadius(8)
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.1)) {
                self.isHovered = isHovered
            }
        }
    }

    private func formattedTime(timeZoneIdentifier: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        return formatter.string(from: Date())
    }

    private func formatTimeDifference(hours: Int, minutes: Int) -> String {
        if hours == 0 && minutes == 0 {
            return "Same time"
        }

        let totalHours = Double(hours) + Double(minutes) / 60.0
        let sign = totalHours < 0 ? "-" : "+"
        return String(format: "%@%.1f hrs", sign, abs(totalHours))
    }

    private func timeDifferenceColor(hours: Int, minutes: Int) -> Color {
        if hours < 0 || (hours == 0 && minutes < 0) {
            return .red
        } else if hours == 0 && minutes == 0 {
            return .gray
        } else {
            return .green
        }
    }
}
