import Combine
import SwiftUI

struct EntryRow: View {
    let entry: Entry
    @State private var isHovered: Bool = false
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var router: Router
    @Environment(\.scenePhase) private var scenePhase
    @State private var currentDate = Date()
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    @Binding var timeOffset: Double

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
                HStack(spacing: 0) {
                    Text(formattedTime(timeZoneIdentifier: entry.timezoneIdentifier))
                        .monospaced()
                        .font(.body)
                        .contentTransition(.numericText())
                }
                Text(formatTimeDifference())
                    .monospaced()
                    .font(.callout)
                    .foregroundColor(.gray)
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
        .onReceive(timer ?? Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            currentDate = Date()
        }
        .onTapGesture {
            router.setActiveRoute(to: .editTimeZone(entryId: entry.id))
        }
        .onChange(of: scenePhase) { newPhase in
            updateTimer(for: newPhase)
        }
        .onAppear {
            updateTimer(for: scenePhase)
        }
    }

    private func formattedTime(timeZoneIdentifier: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)

        // Get the system's locale
        let locale = Locale.current

        // Create a template that includes both 24-hour and 12-hour formats
        let template = "j:mm"

        // Generate the best format for the current locale
        if let formatString = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: locale) {
            formatter.dateFormat = formatString
        } else {
            // Fallback to a default format if generation fails
            formatter.timeStyle = .short
        }
        let offsetDate = Date().addingTimeInterval(timeOffset * 3600)

        return formatter.string(from: offsetDate)
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
            return "same time"
        }

        let totalHours = Double(hours) + Double(minutes) / 60.0

        return String(format: "%+.1f hrs", totalHours)
    }

    private func updateTimer(for phase: ScenePhase) {
        timer?.upstream.connect().cancel()

        switch phase {
        case .active:
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        case .inactive, .background:
            timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
        @unknown default:
            timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
        }
    }
}
