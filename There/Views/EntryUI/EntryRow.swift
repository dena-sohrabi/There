import SwiftUI

struct EntryRow: View {
    let entry: Entry
    @State private var isHovered: Bool = false
    @Environment(\.colorScheme) var scheme

    @State private var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            EntryIcon(entry: entry)
            VStack(alignment: .leading) {
                Text(entry.name.isEmpty ? entry.city : entry.name)
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineLimit(1)
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
                Text(formatTimeDifference())
                    .monospaced()
                    .font(.body)
                    .foregroundColor(timeDifferenceColor())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(isHovered ? scheme == .dark ? Color.white.opacity(0.1) : Color.white.opacity(0.6) : Color.clear)
        .cornerRadius(8)
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.1)) {
                self.isHovered = isHovered
            }
        }
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }

    private func formattedTime(timeZoneIdentifier: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        return formatter.string(from: currentDate)
    }

    private func formatTimeDifference() -> String {
        let userTimeZone = TimeZone.current
        let entryTimeZone = TimeZone(identifier: entry.timezoneIdentifier) ?? .current

        let userDate = currentDate.addingTimeInterval(TimeInterval(userTimeZone.secondsFromGMT()))
        let entryDate = currentDate.addingTimeInterval(TimeInterval(entryTimeZone.secondsFromGMT()))

        let difference = Calendar.current.dateComponents([.hour, .minute], from: userDate, to: entryDate)

        let hours = difference.hour ?? 0
        let minutes = difference.minute ?? 0

        if hours == 0 && minutes == 0 {
            return "Same time"
        }

        let totalHours = Double(hours) + Double(minutes) / 60.0

        return String(format: "%+.1f hrs", totalHours)
    }

    private func timeDifferenceColor() -> Color {
        let userTimeZone = TimeZone.current
        let entryTimeZone = TimeZone(identifier: entry.timezoneIdentifier) ?? .current

        let userDate = currentDate.addingTimeInterval(TimeInterval(userTimeZone.secondsFromGMT()))
        let entryDate = currentDate.addingTimeInterval(TimeInterval(entryTimeZone.secondsFromGMT()))

        let difference = Calendar.current.dateComponents([.hour, .minute], from: userDate, to: entryDate)

        let hours = difference.hour ?? 0
        let minutes = difference.minute ?? 0

        if hours < 0 || (hours == 0 && minutes < 0) {
            return .red
        } else if hours == 0 && minutes == 0 {
            return .gray
        } else {
            return .green
        }
    }
}
