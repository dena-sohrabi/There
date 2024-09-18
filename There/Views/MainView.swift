import AppKit
import GRDB
import PostHog
import SwiftUI

struct MainView: View {
    @State private var email: String = ""
    @StateObject private var fetcher = Fetcher()
    @State private var sortOrder: SortOrder = .timeAscending
    @State private var sortedEntries: [Entry] = []
    @Environment(\.database) var database: AppDatabase
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: Router
    @State private var currentDate = Date()
    @State private var isAtBottom: Bool = false
    @State private var showSlider: Bool = false
    @State var timeOffset: Double = 0

    var body: some View {
        VStack(alignment: sortedEntries.isEmpty ? .center : .leading, spacing: 2) {
            if sortedEntries.isEmpty {
                Spacer()
                EmptyTimezoneView()
                Spacer()
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedEntries) { entry in
                            EntryRow(entry: entry, timeOffset: $timeOffset)
                                .contextMenu {
                                    Button("Edit") {
                                        router.setActiveRoute(to: .editTimeZone(entryId: entry.id))
                                    }
                                    Button("Delete", role: .destructive) {
                                        deleteEntry(entry)
                                    }
                                }

                                .id(entry.id)
                        }
                        .animation(.easeInOut(duration: 0.1), value: sortedEntries.count)
                        Color.clear
                            .frame(height: 2)
                            .onAppear {
                                isAtBottom = false
                            }
                            .onDisappear {
                                isAtBottom = true
                            }
                    }
                    .padding(.horizontal, 6)
                }
                .scrollIndicators(.hidden)
            }
            if showSlider {
                EntryTimeSlider(timeOffset: $timeOffset)
                    .onDisappear {
                        withAnimation {
                            timeOffset = 0.0
                        }
                    }
            }
            BottomBarView(isAtBottom: $isAtBottom, sortOrder: $sortOrder, showSlider: $showSlider)
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 6)
        .onAppear {
            sortEntries()
            decodeAndSetEmail()
        }
        .onChange(of: sortOrder) { _ in
            sortEntries()
        }
        .onChange(of: fetcher.entries) { _ in
            sortEntries()
        }
        .task {
            let id = PostHogSDK.shared.getAnonymousId()
            PostHogSDK.shared.identify(id, userProperties: ["email": email])
        }
//        .onChange(of: timeOffset) { _, _ in
//        }
    }

    private func sortEntries() {
        switch sortOrder {
        case .timeAscending:
            sortedEntries = fetcher.entries.sorted { $0.timeDifference.hours < $1.timeDifference.hours }
        case .timeDescending:
            sortedEntries = fetcher.entries.sorted { $0.timeDifference.hours > $1.timeDifference.hours }
        }
    }

    private func deleteEntry(_ entry: Entry) {
        Task {
            do {
                try await database.dbWriter.write { db in
                    let fetchedEntry = try Entry.fetchOne(db, id: entry.id)
                    try fetchedEntry?.delete(db)
                }
            } catch {
                print("Can't delete entry \(error)")
            }
        }
    }

    private func decodeAndSetEmail() {
        do {
            if let decodedEmail = try SecureKeychainService.shared.retrieveDecrypted(forKey: "userEmail") {
                email = decodedEmail
            }
        } catch {
            print("Error decoding email: \(error)")
        }
    }
}

#Preview {
    MainView()
        .frame(width: 400, height: 400)
}

struct EntryTimeSlider: View {
    @Binding var timeOffset: Double
    @State private var previousValue: Double = 0
    @State var currentHour: Double = Date().hour

    var offset: String {
        if timeOffset == 1 || timeOffset == -1 {
            return "\(timeOffset > 0 ? "+" : "") \(timeOffset) hr"
        } else {
            return "\(timeOffset > 0 ? "+" : "")\(timeOffset) hrs"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(offset)")
                    .monospaced()
                    .font(.callout)
                    .foregroundColor(.gray)

                Spacer()
                Text(formattedTime())
                    .monospaced()
                    .font(.body)
                    .fontWeight(.semibold)
            }
            Slider(value: $currentHour, in: 0 ... 23.5, step: 0.5)
                .onChange(of: currentHour) { newValue in
                    timeOffset = newValue - Date().hour
                    if Int(newValue) != Int(previousValue) {
                        performHapticFeedback()
                    }
                    previousValue = newValue
                }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func formattedTime() -> String {
        let calendar = Calendar.current
        let now = Date()

        let formatter = DateFormatter()

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

        formatter.locale = locale
        let offsetDate = Date().addingTimeInterval(timeOffset * 3600)

        return formatter.string(from: offsetDate)
    }

    private func performHapticFeedback() {
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .default)
    }
}

extension Date {
    var hour: Double {
        Double(Calendar.current.component(.hour, from: self)) + (Calendar.current.component(.minute, from: self) >= 30 ? 0.5 : 0.0)
    }
}
